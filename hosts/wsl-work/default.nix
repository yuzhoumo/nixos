{ config, lib, pkgs, himmelblau, ... }:

{
  imports = [
    ../../modules/common
    ../../modules/developer
    ../../modules/himmelblau
    ../../modules/himmelblau/wsl.nix
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
  # Restart on failure works around a WSL2 race condition where the
  # systemd executor hits EBUSY ("Device or resource busy") because
  # the cgroup hierarchy isn't ready during early boot.
  systemd.services."user@${toString config.users.users.joemo.uid}" = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    overrideStrategy = "asDropin";
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5s";
    };
    unitConfig.StartLimitIntervalSec = 0;
  };

  networking.hostName = "wsl-work";
  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "25.11";
}
