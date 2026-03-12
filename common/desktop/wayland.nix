{ ... }:

{
  services.xserver.enable = true;
  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  security.polkit.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ ];
  };
}
