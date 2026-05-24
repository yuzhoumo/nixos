{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common
    ../../modules/desktop
    ../../modules/developer
  ];

  users.users.joemo.packages = with pkgs; [
    azure-cli
    git-credential-manager
    kubectl
    powershell
    spotify
    teams-for-linux
    (pkgs.makeDesktopItem {
      name = "teams-for-linux";
      desktopName = "Microsoft Teams";
      comment = "Unofficial Microsoft Teams client for Linux";
      icon = "teams-for-linux";
      exec = "teams-for-linux --auth.intune.enabled %U";
      categories = [ "Chat" "InstantMessaging" "Network" ];
    })
  ];

  modules.nixtune = {
    localUser = "joemo";
    entraUser = "joemo@microsoft.com";
    wsl = false;
  };
}
