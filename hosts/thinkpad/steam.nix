{ pkgs, ... }:

{
  imports = [
    ../../modules/steam
  ];

  users.users.ppanda = {
    extraGroups = [ "video" "audio" ];
  };

  # allow ppanda to run commands as steam user without password
  security.sudo.extraRules = [{
    users = [ "ppanda" ];
    runAs = "steam";
    commands = [{
      command = "ALL";
      options = [ "NOPASSWD" "SETENV" ];
    }];
  }];
}
