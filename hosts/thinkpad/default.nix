{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common
    ../../modules/desktop
    ../../modules/developer
    ../../modules/tailscale
    ../../modules/users/ppanda.nix
  ];

  users.users.ppanda = {
    packages = with pkgs; [
      discord
    ];
  };

  networking.hostName = "thinkpad";
  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "25.11";
}
