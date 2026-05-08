{ config, lib, pkgs, ... }:

{
  imports = [
    ../../roles/all
    ../../roles/developer
  ];

  # disable systemd-boot (conflicts with WSL bootloader)
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  wsl.defaultUser = "ppanda";
  wsl.interop.register = true;

  networking.hostName = "wsl-personal";
  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "25.11";
}
