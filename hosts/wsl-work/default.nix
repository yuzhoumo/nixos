{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/common
    ../../modules/developer
    ../../users/joemo.nix
  ];

  environment.systemPackages = with pkgs; [
    azure-cli
    git-credential-manager
    kubectl
    powershell
  ];

  wsl.defaultUser = "joemo";
  wsl.interop.register = true;

  networking.hostName = "wsl-work";
  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "25.11";
}
