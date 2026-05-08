{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/all
    ../../modules/developer
    ../../users/ppanda.nix
  ];

  wsl.defaultUser = "ppanda";
  wsl.interop.register = true;

  networking.hostName = "wsl-personal";
  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "25.11";
}
