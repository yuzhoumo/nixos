{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    clang
    curl
    gcc
    git
    glibc
    htop
    killall
    lspci
    neovim
    tmux
    tree
    unzip
    wget
    zip
  ];
}
