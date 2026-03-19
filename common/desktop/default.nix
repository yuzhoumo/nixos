{ pkgs, ... }:

{
  imports = [
    ./fonts.nix
    ./environment.nix
    ./audio.nix
  ];
}
