{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    age
    clang
    curl
    ethtool
    gcc
    git
    glibc
    htop
    pciutils
    killall
    neovim
    sops
    tmux
    tree
    unzip
    wget
    zip
  ];
}
