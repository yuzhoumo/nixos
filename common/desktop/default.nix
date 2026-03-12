{ pkgs, ... }:

{
  imports = [
    ./hyprland.nix
    ./wayland.nix
  ];
}
