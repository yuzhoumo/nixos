{ pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      corefonts
      nerd-fonts.hack
    ];
    fontconfig.defaultFonts.monospace = [ "Hack Nerd Font" ];
  };
}
