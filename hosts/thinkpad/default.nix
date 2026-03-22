{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common/all
    ../../common/desktop
  ];

  users.users.ppanda = {
    extraGroups = [ "video" "audio" ];
    packages = with pkgs; [
      claude-code
      discord
      docker
      docker-compose
      github-copilot-cli
      go
      mangohud
      opencode
      protonup-qt
      python315
      spotify
      uv
    ];
  };

  networking.hostName = "thinkpad";
  time.timeZone = "America/Los_Angeles";

  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
    };
  };

  hardware.bluetooth.enable = true;
  services.fprintd.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # ThinkPad P14s Gen 5 Intel
  boot.kernelModules = [ "thinkpad_acpi" ];
  services.thermald.enable = true;

  system.stateVersion = "25.11";
}
