{ pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [
      adw-gtk3             # adwaita dark gtk3 theme
      apple-cursor         # cursor theme
      bitwarden-desktop    # password manager
      bluetuith            # bluetooth management tui
      brightnessctl        # screen brightness
      firefox              # web browser
      grim                 # screenshot util
      hyprpaper            # wallpaper manager
      kitty                # terminal emulator
      libnotify            # notification backend
      mako                 # notification frontend
      nautilus             # file browser
      networkmanagerapplet # network manager
      nwg-displays         # display manager
      nwg-look             # gtk theme manager
      pamixer              # volume mixer cli
      pavucontrol          # volume mixer gui
      playerctl            # media control
      rofi                 # app launcher
      slurp                # screen coord selection util
      swayosd              # macos-style osd for volume/brightness
      tor-browser          # web browser
      waybar               # wayland taskbar
      wdisplays            # wayland display configuration
      wl-clipboard         # wayland clipboard
    ];
  };

  programs.dconf.enable    = true; # gnome config store
  programs.hyprland.enable = true; # window compositor
  programs.xwayland.enable = true; # xserver compatibility layer

  services = {
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  security.polkit.enable = true;

  xdg.mime.defaultApplications = {
    "text/html"              = "firefox.desktop";
    "x-scheme-handler/http"  = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ ];
  };
}
