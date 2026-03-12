{ pkgs, ... }:

{
  imports = [
    ./audio.nix
    ./hyprland.nix
    ./wayland.nix
  ];

  programs.light.enable = true;
  environment.systemPackages = [ pkgs.brightnessctl ];
}
