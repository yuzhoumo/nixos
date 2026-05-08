{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../roles/all
    ../../roles/desktop
    ../../roles/developer

    ../../services/tailscale

    ../../users/ppanda.nix
  ];

  networking.hostName = "thinkpad";
  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "25.11";
}
