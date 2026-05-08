{ pkgs, ... }:

{
  users.users.ppanda = {
    packages = with pkgs; [
      github-copilot-cli
      go
      nodejs_24
      opencode
      python315
      spotify
      tor-browser
      uv
    ];
  };

  # generate apropos, whatis, man -k cache
  documentation.man.cache.enable = true;
  documentation.man.generateCaches = true;
}
