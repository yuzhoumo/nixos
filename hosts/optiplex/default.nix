{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../roles/all
    ../../roles/server

    ../../services/dockerhost
    ../../services/ssh
    ../../services/tailscale

    ../../users/ppanda.nix
  ];

  networking.hostName = "optiplex";
  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "25.11";
}
