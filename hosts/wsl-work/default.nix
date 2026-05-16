{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/common
    ../../modules/developer
    ../../modules/users/joemo.nix
  ];

  modules.nixtune = {
    localUser = "joemo";
    entraUser = "joemo@microsoft.com";
    wsl = true;
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

  networking.hostName = "wsl-work";
  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "25.11";
}
