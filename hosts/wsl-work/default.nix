{ config, lib, pkgs, himmelblau, ... }:

{
  imports = [
    ../../modules/common
    ../../modules/developer
    ../../modules/himmelblau
    ../../modules/users/joemo.nix
  ];

  modules.himmelblau = {
    localUser = "joemo";
    entraUser = "joemo@microsoft.com";
  };

  environment.systemPackages = with pkgs; [
    azure-cli
    git-credential-manager
    kubectl
    powershell
    usbutils # lsusb
  ];

  # USB passthrough for FIDO2/YubiKey (via usbipd-win on the Windows host)
  services.udev.enable = true;
  boot.kernelModules = [ "usbip-core" "vhci-hcd" ];

  # WSL doesn't run systemd-modules-load normally, so ensure USB/IP modules
  # are loaded at boot via a oneshot service.
  systemd.services.load-usbip-modules = {
    description = "Load USB/IP kernel modules for usbipd passthrough";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.kmod}/bin/modprobe vhci-hcd";
    };
  };

  # udev rules for FIDO2/YubiKey — allow non-root users to access HID devices.
  # Matches any YubiKey (vendor 1050) and any FIDO HID device (usage page F1D0).
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", MODE="0660", GROUP="users"
  '';

  # Also pull in the community FIDO2 udev rules for broad device support
  services.udev.packages = [ pkgs.libfido2 ];

  # Firefox for browser SSO via linux-entra-sso (auto-configured by himmelblau module)
  programs.firefox.enable = true;

  wsl.defaultUser = "joemo";
  wsl.interop.register = true;

  networking.hostName = "wsl-work";
  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "25.11";
}
