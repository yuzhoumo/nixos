{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common
    ../../modules/dockerhost
    ../../modules/server
    ../../modules/ssh
    ../../modules/tailscale
    ../../modules/users/ppanda.nix
  ];

  networking.hostName = "optiplex";
  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "25.11";
}
