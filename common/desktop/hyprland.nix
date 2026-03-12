{ pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.etc."xdg/waybar/config.jsonc".source = ./waybar/config.jsonc;
  environment.etc."xdg/waybar/style.css".source = ./waybar/style.css;

  environment.systemPackages = with pkgs; [
    bitwarden-desktop
    firefox
    kitty
    mako
    spotify
    waybar
    wofi
  ];
}
