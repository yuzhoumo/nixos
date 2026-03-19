{ pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment = {
    systemPackages = with pkgs; [
      # core system utilities
      apple-cursor  # cursor theme
      brightnessctl # screen brightness
      grim          # screenshot util
      hyprpaper     # wallpaper manager
      kitty         # terminal emulator
      mako          # notifications
      nautilus      # file browser
      rofi          # app launcher
      slurp         # screen coord selection util
      waybar        # taskbar
      wdisplays     # display manager
      wl-clipboard  # clipboard

      networkmanagerapplet # todo: find a better one

      # default user apps
      bitwarden-desktop
      firefox
      spotify
    ];

    # hyprland configurations
    etc."hypr/hyprland.conf".source = ./hyprland/hyprland.conf;

    # waybar configurations
    etc."xdg/waybar/config.jsonc".source = ./waybar/config.jsonc;
    etc."xdg/waybar/style.css".source = ./waybar/style.css;
  };

  services = {
    xserver.enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };

  security.polkit.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ ];
  };
}
