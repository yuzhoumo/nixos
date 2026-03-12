{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    clang
    curl
    gcc
    git
    glibc
    htop
    pciutils
    killall
    neovim
    tmux
    tree
    unzip
    wget
    zip
  ];
}
