{ pkgs, ... }:

{
  imports = [
    ./audio.nix
    ./fonts
    ./environment.nix
    ./wayland.nix
  ];
}
