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

  hardware.cpu.intel.updateMicrocode = true;

  networking.hostName = "optiplex";
  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "25.11";
}
