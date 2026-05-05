{ config, pkgs, ... }:

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

  sops.secrets = {
    tailscale-oauth-optiplex = {
      owner = "root";
      restartUnits = [ "tailscaled-autoconnect.service" ];
    };
  };

  services.tailscale = {
    authKeyFile = config.sops.secrets.tailscale-oauth-optiplex.path;
    authKeyParameters.ephemeral = false;
    authKeyParameters.preauthorized = true;
    extraUpFlags = [
      "--advertise-tags=tag:self-auth,tag:minecraft"
      "--advertise-exit-node"
      "--ssh"
    ];
  };

  networking.hostName = "optiplex";
  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "25.11";
}
