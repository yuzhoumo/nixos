{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../roles/all
    ../../roles/desktop
    ../../roles/developer
    ../../services/tailscale
    ../../services/steam
  ];

  users.users.ppanda = {
    extraGroups = [ "video" "audio" ];
  };

  # Allow ppanda to run commands as the steam user without a password
  security.sudo.extraRules = [{
    users = [ "ppanda" ];
    runAs = "steam";
    commands = [{
      command = "ALL";
      options = [ "NOPASSWD" "SETENV" ];
    }];
  }];

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "lock";
    HandleLidSwitchDocked = "ignore";
  };

  powerManagement.enable = true; # nixos stock power management

  networking.hostName = "thinkpad";
  time.timeZone = "America/Los_Angeles";

  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
    };
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
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
