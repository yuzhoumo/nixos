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

  users.users.ppanda.packages = with pkgs; [ discord ];
  modules.steam.user = "ppanda";

  programs.firefox.enable = true;

  modules.nixtune = {
    localUser = "joemo";
    entraUser = "joemo@microsoft.com";
  };

  networking.hostName = "thinkpad";
  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "25.11";
}
