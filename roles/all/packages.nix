{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    age
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
