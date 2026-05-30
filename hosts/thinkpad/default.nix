{ pkgs, ... }:

{
  imports = [
    ../../modules/common
    ../../modules/desktop
    ../../modules/developer
    ../../modules/steam
    ../../modules/tailscale
    ../../modules/firefox
    ./hardware-configuration.nix
    ./personal.nix
    ./work.nix
  ];

  networking.hostName = "thinkpad";
  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "25.11";
}
