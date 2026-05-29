{ config, pkgs, ... }:

{
  imports = [
    ../../modules/common
    ../../modules/desktop
    ../../modules/developer
    ../../modules/users/joemo.nix
  ];

  users.users.joemo.packages = with pkgs; [
    azure-cli
    git-credential-manager
    kubectl
    powershell
    spotify
    teams-for-linux
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

  system.activationScripts.teams-for-linux-config.text = let
    configFile = pkgs.writeText "teams-for-linux-config.json" (builtins.toJSON {
      auth.intune = {
        enabled = true;
        user = "joemo@microsoft.com";
      };
    });
    home = config.users.users.joemo.home;
  in ''
    mkdir -p "${home}/.config/teams-for-linux"
    cp -f "${configFile}" "${home}/.config/teams-for-linux/config.json"
    chown -R joemo:$(id -gn joemo) "${home}/.config/teams-for-linux"
  '';
}
