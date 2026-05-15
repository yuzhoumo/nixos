{ config, lib, pkgs, himmelblau, ... }:

{
  imports = [
    ../../modules/common
    ../../modules/developer
    ../../modules/himmelblau
    ../../modules/himmelblau/intune-csr-fix.nix
    ../../modules/users/joemo.nix
  ];

  modules.himmelblau = {
    localUser = "joemo";
    entraUser = "joemo@microsoft.com";
  };

  environment.systemPackages = with pkgs; [
    azure-cli
    git-credential-manager
    kubectl
    powershell
    usbutils # lsusb
  ];

  # Firefox for browser SSO via linux-entra-sso (auto-configured by himmelblau module)
  programs.firefox.enable = true;

  wsl.defaultUser = "joemo";
  wsl.interop.register = true;

  # Enable lingering so systemd --user starts at boot (needed for
  # himmelblau-broker D-Bus service and linux-entra-sso)
  users.users.joemo.linger = true;

  # WSL's systemd-logind doesn't honor linger files, so the user
  # manager (and therefore user D-Bus) won't auto-start. Force it.
  systemd.services."user@${toString config.users.users.joemo.uid}" = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    overrideStrategy = "asDropin";
  };

  networking.hostName = "wsl-work";
  time.timeZone = "America/Los_Angeles";

  # WSL2 has broken IPv6 — outbound connections fail with EAFNOSUPPORT.
  # Disable it so reqwest (and everything else) uses IPv4.
  boot.kernel.sysctl."net.ipv6.conf.all.disable_ipv6" = 1;
  boot.kernel.sysctl."net.ipv6.conf.default.disable_ipv6" = 1;

  system.stateVersion = "25.11";
}
