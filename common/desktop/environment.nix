{ pkgs, ... }:

{
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
      wdisplays     # display configuration
      wl-clipboard  # clipboard

      networkmanagerapplet # todo: find a better one

      # default user apps
      bitwarden-desktop
      firefox
      spotify
    ];

    # write config files to /etc
    etc."xdg/hypr/hyprland.conf".source = ./hyprland/hyprland.conf;
    etc."xdg/waybar/config.jsonc".source = ./waybar/config.jsonc;
    etc."xdg/waybar/style.css".source = ./waybar/style.css;
  };

  programs.dconf.enable = true;

  programs.hyprland = {
    enable = true;

    # enable xwayland for backwards compatability
    xwayland.enable = true;

    # override configuration location
    package = pkgs.hyprland.overrideAttrs {
      postFixup = ''
        wrapProgram $out/bin/Hyprland --add-flags "--config /etc/xdg/hypr/hyprland.conf"
      '';
    };
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
