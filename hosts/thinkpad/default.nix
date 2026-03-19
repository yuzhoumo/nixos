{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common
    ../../common/desktop
  ];

  users.users.ppanda = {
    extraGroups = [ "video" "audio" ];
    packages = with pkgs; [
      docker
      docker-compose
      claude-code
      github-copilot-cli
      opencode
      go
      mangohud
      protonup-qt
      python315
      uv
    ];
  };

  networking.hostName = "thinkpad";
  time.timeZone = "America/Los_Angeles";

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

  # Fingerprint reader
  services.fprintd.enable = true;

  # Graphics (Intel Iris Xe)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
  programs.gamemode.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  system.stateVersion = "25.11";
}
