{ config, lib, pkgs, himmelblau, ... }:

{
  imports = [
    ../../modules/common
    ../../modules/developer
    ../../modules/himmelblau
    ../../users/joemo.nix
  ];

  modules.himmelblau = {
    localUser = "joemo";
    entraUser = "joemo@microsoft.com";
    enableBroker = true;
  };

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
