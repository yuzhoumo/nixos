{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common/all
    ../../common/server
  ];

  networking.hostName = "optiplex";
  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "25.11";
}
