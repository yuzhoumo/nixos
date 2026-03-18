{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common
    ../../common/desktop
  ];

  networking.hostName = "thinkpad";
  time.timeZone = "America/Los_Angeles";

  # ThinkPad P14s Gen 5 Intel
  boot.kernelModules = [ "thinkpad_acpi" ];
  services.thermald.enable = true;

  environment.systemPackages = [ pkgs.brightnessctl ];

  # Trackpad
  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
    };
  };

  # Fingerprint reader
  services.fprintd.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  users.users.ppanda = {
    extraGroups = [ "video" "audio" ];
    packages = with pkgs; [
      docker
      docker-compose
      github-copilot-cli
      go
      python315
      uv
    ];
  };

  system.stateVersion = "25.11";
}
