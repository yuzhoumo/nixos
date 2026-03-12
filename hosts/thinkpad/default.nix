{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common
    ../../common/desktop
  ];

  networking.hostName = "thinkpad";

  users.users.ppanda.packages = with pkgs; [
    docker
    docker-compose
    go
    python315
    uv
  ];

  system.stateVersion = "25.11";
}
