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

  hardware.cpu.intel.updateMicrocode = true; # meltdown/spectre tweaks

  powerManagement = {
    cpuFreqGovernor = "schedutil"; # cpu frequency scaling
    powertop.enable = true; # auto-tune USB/PCIe/SATA power management
  };

  services = {
    fstrim.enable = true; # enable ssd trim
    thermald.enable = true; # intel thermal management daemon
  };

  networking.hostName = "optiplex";
  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "25.11";
}
