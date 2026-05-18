{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/common
    ../../modules/developer
    ../../modules/users/ppanda.nix
  ];

  wsl.defaultUser = "ppanda";
  wsl.interop.register = true;

  networking.hostName = "wsl-personal";
  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "25.11";
}
