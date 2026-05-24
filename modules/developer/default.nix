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
}
