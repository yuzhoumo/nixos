{ pkgs, ... }:

{
  users.users.joemo = {
    isNormalUser = true;
    description = "Joe Mo";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    home = "/home/joemo";
  };
}
