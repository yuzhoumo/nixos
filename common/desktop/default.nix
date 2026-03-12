{ pkgs, ... }:

{
  imports = [
    ./audio.nix
    ./hyprland.nix
    ./wayland.nix
  ];
}
