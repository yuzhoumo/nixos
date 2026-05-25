{ config, lib, pkgs, ... }:

let
  cfg = config.programs.azurevpn;
  azureVpnPackage = pkgs.callPackage ./package.nix { };
in
{
  options.programs.azurevpn = {
    enable = lib.mkEnableOption "Microsoft Azure VPN Client";

    profileFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Path to an Azure VPN client connection profile XML file.
        When set, the profile is copied into each profile user's
        ~/.local/share/microsoft-azurevpnclient/profiles/ directory
        so the client picks it up on launch.
        Intended for use with sops-nix decrypted secret paths.
      '';
    };

    profileName = lib.mkOption {
      type = lib.types.str;
      default = "profile.xml";
      description = ''
        Filename for the imported VPN profile.
      '';
    };

    profileUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        List of usernames whose Azure VPN client profile directories
        should be populated with the connection profile.
      '';
    };

    polkitGroup = lib.mkOption {
      type = lib.types.str;
      default = "wheel";
      description = ''
        Unix group whose members may control systemd-resolved via polkit,
        required for Azure VPN Client DNS management.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ azureVpnPackage pkgs.zenity ];

    services.resolved.enable = true;

    # Security wrapper to grant CAP_NET_ADMIN for tun device creation
    security.wrappers.azurevpnclient = {
      source = "${azureVpnPackage}/bin/azurevpnclient-unprivileged";
      owner = "root";
      group = "root";
      capabilities = "cap_net_admin+eip";
    };

    # Polkit rule to allow the VPN client to manage DNS via resolved
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (
          action.id.indexOf("org.freedesktop.resolve1.") == 0 &&
          subject.isInGroup("${cfg.polkitGroup}")
        ) { return polkit.Result.YES; }
      });
    '';

    # DigiCert root CA required for Azure VPN server validation
    environment.etc."ssl/certs/DigiCert_Global_Root_G2.pem".source =
      pkgs.runCommand "azurevpn-digicert-global-root-g2.pem" { } ''
        sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' \
          ${pkgs.cacert.unbundled}/etc/ssl/certs/DigiCert_Global_Root_G2:33af1e6a711a9a0bb2864b11d09fae5.crt > "$out"
      '';

    # Deploy VPN profile and register it in the Flutter client's preferences
    system.activationScripts.azurevpn-profile = lib.mkIf (cfg.profileFile != null) {
      deps = [ "setupSecrets" ];
      text = let
        xmllint = "${pkgs.libxml2}/bin/xmllint";
        jq = "${pkgs.jq}/bin/jq";
        xpath = field: "--xpath \"//*[local-name()='${field}']/text()\"";
      in lib.concatMapStringsSep "\n" (user: let
        home = config.users.users.${user}.home;
        dataDir = "${home}/.local/share/microsoft-azurevpnclient";
        profileDir = "${dataDir}/profiles";
        prefsFile = "${dataDir}/shared_preferences.json";
      in ''
        mkdir -p "${profileDir}"
        cp -f "${cfg.profileFile}" "${profileDir}/${cfg.profileName}"

        # Parse profile XML and register in shared_preferences.json
        _xml="${profileDir}/${cfg.profileName}"
        _name=$(${xmllint} ${xpath "AzVpnProfile']/*[local-name()='name"} "$_xml" 2>/dev/null || echo "")
        _fqdn=$(${xmllint} ${xpath "serverlist']/*[local-name()='ServerEntry'][1]/*[local-name()='fqdn"} "$_xml" 2>/dev/null || echo "")
        _auth=$(${xmllint} ${xpath "clientauth']/*[local-name()='type"} "$_xml" 2>/dev/null || echo "")
        _tenant=$(${xmllint} ${xpath "aad']/*[local-name()='tenant"} "$_xml" 2>/dev/null || echo "")
        _audience=$(${xmllint} ${xpath "aad']/*[local-name()='audience"} "$_xml" 2>/dev/null || echo "")
        _issuer=$(${xmllint} ${xpath "aad']/*[local-name()='issuer"} "$_xml" 2>/dev/null || echo "")
        _secret=$(${xmllint} ${xpath "serversecret"} "$_xml" 2>/dev/null || echo "")
        _hash=$(${xmllint} ${xpath "Cert']/*[local-name()='hash"} "$_xml" 2>/dev/null || echo "")
        _servers=$(${xmllint} --xpath "count(//*[local-name()='ServerEntry'])" "$_xml" 2>/dev/null || echo "1")
        if [ "$_servers" -gt 1 ] 2>/dev/null; then _ha="true"; else _ha="false"; fi

        _entry="{server_name: $_name, fqdn: $_fqdn, profile_file_path: ${profileDir}/${cfg.profileName}, profile_file_name: ${cfg.profileName}, server_secret: $_secret, auth_type: $_auth, tenant: $_tenant, audience: $_audience, issuer: $_issuer, cert_hash: $_hash, cert_public_data_file_path: , cert_public_data_file_name: , cert_private_key_file_path: , cert_private_key_file_name: , is_highly_available: $_ha, last_logged_user: , msal_cache: , cert_passphrase: , profile_data: , status: }"

        if [ -f "${prefsFile}" ]; then
          # Remove any existing entry for this profile file, then add the new one
          ${jq} --arg entry "$_entry" --arg pfn "${cfg.profileName}" \
            '."flutter.profiles" = ([."flutter.profiles"[]? | select(contains($pfn) | not)] + [$entry])' \
            "${prefsFile}" > "${prefsFile}.tmp" && mv "${prefsFile}.tmp" "${prefsFile}"
        else
          ${jq} -n --arg entry "$_entry" \
            '{"flutter.profiles": [$entry]}' > "${prefsFile}"
        fi

        chown -R ${user}:$(id -gn ${user}) "${dataDir}"
      '') cfg.profileUsers;
    };
  };
}
