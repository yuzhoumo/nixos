{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../roles/all
    ../../roles/desktop
    ../../services/docker
  ];

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

  networking.hostName = "wsl-personal";
  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "25.11";
}
