{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common
    ../../modules/server
    ../../modules/dockerhost
    ../../modules/ssh
    ../../modules/tailscale
    ../../users/ppanda.nix
  ];

  networking.hostName = "optiplex";
  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "25.11";
}
