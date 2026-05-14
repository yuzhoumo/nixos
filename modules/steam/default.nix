{ config, pkgs, lib, ... }:

let
  cfg = config.modules.steam;

  setfacl = "${pkgs.acl}/bin/setfacl";
  xhost = "${pkgs.xhost}/bin/xhost";

  # Wrapper that forwards display/audio sockets and runs steam as the steam user.
  steam-session = pkgs.writeShellScriptBin "steam-session"
    (builtins.replaceStrings [ "@setfacl@" "@xhost@" ] [ setfacl xhost ]
      (builtins.readFile ./session.sh));

  # Override Steam's .desktop file to use the wrapper
  steam-desktop = pkgs.makeDesktopItem {
    name = "steam";
    desktopName = "Steam";
    comment = "Application for managing and playing games on Steam";
    icon = "steam";
    exec = "steam-session %U";
    categories = [ "Network" "FileTransfer" "Game" ];
    mimeTypes = [ "x-scheme-handler/steam" "x-scheme-handler/steamlink" ];
  };
in
{
  options.modules.steam = {
    user = lib.mkOption {
      type = lib.types.str;
      description = "User who can launch Steam as the dedicated steam user";
    };
  };

  config = {
    # Dedicated user for Steam/games
    users.users.steam = {
      isNormalUser = true;
      description = "Steam";
      home = "/home/steam";
      extraGroups = [ "video" "audio" "input" ];
    };

    # Enable lingering so systemd creates /run/user/<steam-uid> at boot
    systemd.tmpfiles.rules = [
      "f /var/lib/systemd/linger/steam"
    ];

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
    programs.gamemode.enable = true;

    environment.systemPackages = [ steam-session steam-desktop ];

    # Grant the calling user access to audio/video devices
    users.users.${cfg.user} = {
      extraGroups = [ "video" "audio" ];
    };

    # Allow the calling user to run commands as steam user without password
    security.sudo.extraRules = [{
      users = [ cfg.user ];
      runAs = "steam";
      commands = [{
        command = "ALL";
        options = [ "NOPASSWD" "SETENV" ];
      }];
    }];
  };
}
