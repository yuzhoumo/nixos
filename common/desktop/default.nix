{ pkgs, ... }:

{
  imports = [
    ./audio.nix
    ./fonts
    ./hyprland.nix
    ./wayland.nix
  ];
}
