{ pkgs, ... }:

{
  imports = [
    ./networking.nix
    ./security.nix
  ];

  services.xserver.enable = false;
}
