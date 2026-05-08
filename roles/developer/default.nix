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
}
