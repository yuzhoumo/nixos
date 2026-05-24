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

    # Deploy VPN profile into each user's app data directory
    system.activationScripts.azurevpn-profile = lib.mkIf (cfg.profileFile != null) {
      deps = [ "setupSecrets" ];
      text = lib.concatMapStringsSep "\n" (user: let
        home = config.users.users.${user}.home;
        dir = "${home}/.local/share/microsoft-azurevpnclient/profiles";
      in ''
        mkdir -p "${dir}"
        cp -f "${cfg.profileFile}" "${dir}/${cfg.profileName}"
        chown -R ${user}:$(id -gn ${user}) "${home}/.local/share/microsoft-azurevpnclient"
      '') cfg.profileUsers;
    };
  };
}
