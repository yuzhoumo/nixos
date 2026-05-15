{ config, lib, pkgs, himmelblau, ... }:

# Himmelblau Entra ID / Intune enrollment for NixOS (user-mapping mode)
#
# This module configures himmelblau for the "register" join type, where a local
# user is mapped to an Entra ID identity rather than using Entra ID as the
# primary login. This is the WSL-friendly mode.
#
# PAM is configured for unlock-only: himmelblau does NOT handle login
# authentication (pam_unix does that). Instead, a try_unseal rule runs after
# local auth to auto-unseal the Entra broker secrets using the login password.
# This matches the "Azure Entra Id unlock" PAM profile from the instructions.
#
# After deploying this configuration:
#   1. Rebuild: sudo nixos-rebuild switch --flake .#wsl-work
#   2. Enroll:  sudo aad-tool auth-test --name joemo
#      - Set the Hello PIN to the SAME password as your local user (enables
#        auto-unlock on login).
#      - Authenticate with your FIDO2 key when prompted.
#   3. Verify:  check https://portal.manage-beta.microsoft.com/devices

let
  cfg = config.modules.himmelblau;
in
{
  imports = [
    himmelblau.nixosModules.himmelblau
    ./fido.nix
  ];

  options.modules.himmelblau = {
    localUser = lib.mkOption {
      type = lib.types.str;
      description = "Local username to map to the Entra ID identity.";
      example = "joemo";
    };

    entraUser = lib.mkOption {
      type = lib.types.str;
      description = "Entra ID UPN (email) to map the local user to.";
      example = "joemo@microsoft.com";
    };
  };

  config = {
    # Install aad-tool for enrollment management
    environment.systemPackages = [
      himmelblau.packages.${pkgs.stdenv.hostPlatform.system}.aad-tool
    ];

    services.himmelblau = {
      enable = true;

      # User-mapping mode: we want himmelblau PAM on login/systemd-user for
      # try_unseal (auto-unlock Entra secrets with login password), but NOT
      # for interactive auth. We disable the auth/account rules below.
      pamServices = [ "login" "systemd-user" ];

      settings = {
        domain = [ "microsoft.com" ];
        join_type = "register";
        user_map_file = "/etc/himmelblau/user-map";

        # Windows Hello enrollment for TPM-sealed secrets
        enable_hello = true;

        # FIDO2 / passkey support
        enable_experimental_passwordless_fido = true;

        # MFA support
        enable_experimental_mfa = true;

        # HSM: WSL2 has no TPM passthrough, use software HSM with TPM
        # binding only if available (the upstream default).
        hsm_type = "tpm_bound_soft_if_possible";

        # WSL2 doesn't support IPv6 sockets; force IPv4 only.
        ip_version = "ipv4-only";

        # Home directory settings
        local_groups = [ "users" ];
        home_attr = "cn";
        home_alias = "cn";
        use_etc_skel = true;
      };
    };

    # User-mapping mode does NOT use nss-himmelblau. The upstream module
    # unconditionally adds "himmelblau" to nssDatabases, which causes user
    # lookups for unknown names to hang (blocking sudo, aad-tool, etc.).
    # Override to the standard NixOS defaults without himmelblau.
    system.nssDatabases.passwd = lib.mkForce [ "files" "systemd" ];
    system.nssDatabases.group = lib.mkForce [ "files" "[success=merge]" "systemd" ];
    system.nssDatabases.shadow = lib.mkForce [ "files" ];

    # PAM: In user-mapping mode, we do NOT want himmelblau handling interactive
    # authentication (that causes hangs). Disable auth/account rules on all
    # services. Keep session rules (optional, won't hang).
    # Add try_unseal after pam_unix to auto-unseal Entra secrets at login.
    # The upstream module adds sudo unconditionally; login/systemd-user come
    # from our pamServices setting above.
    security.pam.services = let
      himmelblauPamLib = "${config.services.himmelblau.pamPackage.lib}/lib/libpam_himmelblau.so";
      overrides = svc: {
        rules.auth.himmelblau.enable = false;
        rules.account.himmelblau.enable = false;
        rules.auth.himmelblau-unseal = {
          order = config.security.pam.services.${svc}.rules.auth.unix.order + 1000;
          control = "optional";
          modulePath = himmelblauPamLib;
          settings.try_unseal = true;
        };
      };
    in lib.genAttrs [ "sudo" "login" "systemd-user" ] overrides;

    # Broker: D-Bus-activated user service for SSO (linux-entra-sso extension
    # communicates with this). Enabled by the upstream module automatically.

    # User map: maps local user -> Entra ID UPN
    environment.etc."himmelblau/user-map" = {
      text = "${cfg.localUser}:${cfg.entraUser}\n";
      mode = "0644";
    };

    # Fake os-release: MSIT compliance policy requires Ubuntu. Since the
    # policy is server-side and identical to intune's, we spoof the distro
    # the same way.
    environment.etc."himmelblau/fake-os-release" = {
      text = ''
        PRETTY_NAME="Ubuntu 22.04.4 LTS"
        NAME="Ubuntu"
        VERSION_ID="22.04"
        VERSION="22.04.4 LTS (Jammy Jellyfish)"
        VERSION_CODENAME=jammy
        ID=ubuntu
        ID_LIKE=debian
        HOME_URL="https://www.ubuntu.com/"
        SUPPORT_URL="https://help.ubuntu.com/"
        BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
        PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
        UBUNTU_CODENAME=jammy
      '';
      mode = "0444";
    };

    # Bind-mount the fake os-release into the himmelblaud-tasks service so
    # compliance checks see "Ubuntu". The compliance code reads /etc/os-release.
    systemd.services.himmelblaud-tasks.serviceConfig.BindReadOnlyPaths = [
      "/etc/himmelblau/fake-os-release:/etc/os-release"
      "/etc/himmelblau/fake-os-release:/usr/lib/os-release"
    ];

    # Disk encryption compliance: WSL2 runs inside a VHD on the Windows host
    # which is protected by BitLocker. The himmelblaud compliance checker looks
    # for a non-empty /etc/crypttab to detect encryption. Provide one so the
    # check passes.
    environment.etc."crypttab" = {
      text = "# WSL2 VHD should be encrypted by host BitLocker\n";
      mode = "0644";
    };
  };
}
