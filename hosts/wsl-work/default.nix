{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/common
    ../../modules/developer
    ../../modules/users/joemo.nix
  ];

  programs.azurevpn.enable = true;

  # Set the default WSL user and enable Windows interop
  wsl.defaultUser = "joemo";
  wsl.interop.register = true;

  modules.nixtune = {
    enable = true;
    localUser = "joemo";
    entraUser = "joemo@microsoft.com";
    wsl = true;
  };

  environment.systemPackages = with pkgs; [
    azure-cli
    git-credential-manager
    kubectl
    powershell
    usbutils # lsusb
  ];

  # Firefox for browser SSO via linux-entra-sso (auto-configured by himmelblau module)
  # Force d3d12 gallium driver instead of zink to avoid Mesa/EGL GPU crashes on WSL
  # Force XWayland to work around broken context menus under native Wayland on WSL
  programs.firefox.enable = true;
  environment.variables.GALLIUM_DRIVER = "d3d12";
  environment.variables.MOZ_ENABLE_WAYLAND = "0";
  environment.variables.MOZ_GTK_TITLEBAR_DECORATION = "client";

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
    ];
  };

  networking.hostName = "wsl-work";
  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "25.11";
}
