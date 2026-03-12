{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common
    ../../common/desktop
  ];

  networking.hostName = "thinkpad";

  # ThinkPad P14s Gen 5 Intel
  boot.kernelModules = [ "thinkpad_acpi" ];
  services.thermald.enable = true;

  # Trackpad
  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
    };
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  users.users.ppanda = {
    extraGroups = [ "video" "audio" ];
    packages = with pkgs; [
      docker
      docker-compose
      go
      python315
      uv
    ];
  };

  system.stateVersion = "25.11";
}
