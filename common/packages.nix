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
    neovim
    tmux
    tree
    unzip
    wget
    zip
  ];
}
