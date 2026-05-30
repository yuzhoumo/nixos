{ config, pkgs, ... }:

{
  imports = [
    ../../modules/users/joemo.nix
  ];

  users.users.joemo.packages = with pkgs; [
    azure-cli
    git-credential-manager
    kubectl
    powershell
    spotify
  ];

  sops.secrets.azure-vpn-profile = {
    sopsFile = ../../secrets/azvpn-profile.xml;
    format = "binary";
  };

  programs.azurevpnclient = {
    enable = true;
    profileFile = config.sops.secrets.azure-vpn-profile.path;
    profileName = "MSFT-AzVPN-TEST.xml";
    profileUsers = [ "joemo" ];
  };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
    ];
  };

  modules.nixtune = {
    enable = true;
    localUser = "joemo";
    entraUser = "joemo@microsoft.com";
    wsl = false;
  };

  modules.teams = {
    user = "joemo";
    entraUser = "joemo@microsoft.com";
  };
}
