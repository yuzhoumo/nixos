{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../roles/all
    ../../roles/server
    ../../services/tailscale
  ];

  networking.hostName = "ingress";
  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "25.11";
}
