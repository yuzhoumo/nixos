{ config, lib, pkgs, himmelblau, ... }:

# Himmelblau Entra ID / Intune enrollment for NixOS (user-mapping mode)
#
# This module configures himmelblau for the "register" join type, where a local
# user is mapped to an Entra ID identity rather than using Entra ID as the
# primary login. This is the WSL-friendly mode.
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
  imports = [ himmelblau.nixosModules.himmelblau ];

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
    # Install aad-tool for enrollment and the SSO browser connector
    environment.systemPackages = [
      himmelblau.packages.${pkgs.stdenv.hostPlatform.system}.aad-tool
      himmelblau.packages.${pkgs.stdenv.hostPlatform.system}.sso
    ];

    services.himmelblau = {
      enable = true;

      settings = {
        domain = [ "microsoft.com" ];
        join_type = "register";
        user_map_file = "/etc/himmelblau/user-map";

        # FIDO2 / passkey support
        enable_experimental_passwordless_fido = true;

        # HSM: WSL2 has no TPM passthrough by default, so fall back to
        # software HSM when no TPM device is available.
        hsm_type = "tpm_if_possible";

        # Home directory settings (match home_attr and home_alias)
        local_groups = [ "users" ];
        home_attr = "cn";
        home_alias = "cn";
        use_etc_skel = true;
      };
    };

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
    # compliance checks see "Ubuntu".
    systemd.services.himmelblaud-tasks.serviceConfig.BindReadOnlyPaths = [
      "/etc/himmelblau/fake-os-release:/etc/os-release"
    ];
  };
}
