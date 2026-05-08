{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    github-copilot-cli
    go
    nodejs_24
    opencode
    python315
    spotify
    uv
  ];

  # generate apropos, whatis, man -k cache
  documentation.man.cache.enable = true;
  documentation.man.generateCaches = true;
}
