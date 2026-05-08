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
    ssh-to-age
    tmux
    tree
    unzip
    wget
    zip
  ];
}
