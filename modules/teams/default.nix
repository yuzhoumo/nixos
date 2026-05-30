{ config, pkgs, lib, ... }:

let
  cfg = config.modules.teams;

  configFile = pkgs.writeText "teams-for-linux-config.json" (builtins.toJSON {
    auth.intune = {
      enabled = true;
      user = cfg.entraUser;
    };
  });

  home = config.users.users.${cfg.user}.home;
in
{
  options.modules.teams = {
    user = lib.mkOption {
      type = lib.types.str;
      description = "Local user to install and configure teams-for-linux for";
    };

    entraUser = lib.mkOption {
      type = lib.types.str;
      description = "Entra ID email address used for teams-for-linux Intune auth";
    };
  };

  config = {
    users.users.${cfg.user}.packages = [ pkgs.teams-for-linux ];

    system.activationScripts.teams-for-linux-config.text = ''
      mkdir -p "${home}/.config/teams-for-linux"
      cp -f "${configFile}" "${home}/.config/teams-for-linux/config.json"
      chown -R ${cfg.user}:$(id -gn ${cfg.user}) "${home}/.config/teams-for-linux"
    '';
  };
}
