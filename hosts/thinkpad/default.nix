{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common/desktop
  ];

  networking.hostName = "thinkpad";

  users.users.ppanda.packages = with pkgs; [
    bitwarden-desktop
    docker
    docker-compose
    firefox
    go
    python315
    spotify
    uv
  ];

  system.stateVersion = "25.11";
}
