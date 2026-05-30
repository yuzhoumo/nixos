{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    github-copilot-cli
    go
    nodejs_24
    opencode
    python315
    uv
  ];

  # generate apropos, whatis, man -k cache
  documentation.man.cache.enable = true;

  # provides /lib64/ld-linux-x86-64.so.2, allowing foreign binaries to run
  programs.nix-ld.enable = true;
}
