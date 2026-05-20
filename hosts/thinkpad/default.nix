{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common
    ../../modules/desktop
    ../../modules/developer
    ../../modules/steam
    ../../modules/tailscale
    ../../modules/users/ppanda.nix
    ../../modules/users/joemo.nix
  ];

  modules.steam.user = "ppanda";
  users.users.ppanda.packages = with pkgs; [
    discord
  ];

  users.users.joemo.packages = with pkgs; [
    azure-cli
    git-credential-manager
    kubectl
    powershell
  ];

  modules.nixtune = {
    localUser = "joemo";
    entraUser = "joemo@microsoft.com";
  };

  networking.hostName = "thinkpad";
  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "25.11";
}
