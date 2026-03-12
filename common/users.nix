{ pkgs, ... }:

{
  users.users.ppanda = {
    isNormalUser = true;
    description = "PerpetualPanda";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    home = "/home/ppanda";
  };
}
