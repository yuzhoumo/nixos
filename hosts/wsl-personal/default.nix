{ config, lib, pkgs, ... }:

{
  imports = [
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

  # disable systemd-boot (conflicts with WSL bootloader)
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  wsl.defaultUser = "ppanda";

  networking.hostName = "wsl-personal";
  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "25.11";
}
