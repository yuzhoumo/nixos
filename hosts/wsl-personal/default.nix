{ config, lib, pkgs, ... }:

{
  imports = [
    <nixos-wsl/modules>
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

  wsl.enable = true;
  wsl.defaultUser = "ppanda";

  networking.hostName = "wsl-personal";
  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "25.11";
}
