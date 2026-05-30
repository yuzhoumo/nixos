{ pkgs, ... }:

{
  imports = [
    ../../modules/users/ppanda.nix
  ];

  modules.steam.user = "ppanda";
  users.users.ppanda.packages = with pkgs; [
    discord
    spotify
  ];
}
