{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../roles/all
    ../../roles/server
    ../../services/docker
    ../../services/ssh
    ../../services/tailscale
  ];

  networking.hostName = "optiplex";
  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "25.11";
}
