{ config, lib, pkgs, ... }:

{
  imports = [
    ../../roles/all
    ../../roles/developer
  ];

  wsl.defaultUser = "joemo";
  wsl.interop.register = true;

  networking.hostName = "wsl-work";
  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "25.11";
}
