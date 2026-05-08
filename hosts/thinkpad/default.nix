{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/all
    ../../modules/desktop
    ../../modules/developer
    ../../modules/tailscale
    ../../users/ppanda.nix
  ];

  networking.hostName = "thinkpad";
  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "25.11";
}
