{ pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

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
