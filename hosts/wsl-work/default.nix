{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/common
    ../../modules/developer
    ../../modules/users/joemo.nix
    ../../modules/firefox
  ];

  # Set the default WSL user and enable Windows interop
  wsl = {
    defaultUser = "joemo";
    interop.register = true;

    # Azure VPN runs inside this WSL distro, so systemd-resolved (enabled by
    # the azurevpnclient module) must own DNS for the tunnel's split-DNS to work.
    # Stop WSL from regenerating /etc/resolv.conf, which otherwise points at
    # the WSL DNS proxy and shadows resolved.
    wslConf.network.generateResolvConf = false;
  };

  # Pin a UID distinct from other concurrently-running WSL distros. WSL2
  # shares one kernel and cgroup tree across distros, so a duplicate UID
  # collides on user-<uid>.slice and user@<uid>.service fails with
  # "Failed to spawn executor: Device or resource busy".
  users.users.joemo.uid = 1001;

  # Ordered DNS upstreams for resolved. 10.255.255.254 is the WSL DNS-tunneling
  # endpoint that forwards to the Windows host's DNS and follows host network
  # changes; fallback to mullvad public dns resolver
  networking.nameservers = [ "10.255.255.254" "194.242.2.2" ];

  sops.secrets.azure-vpn-profile = {
    sopsFile = ../../secrets/azvpn-profile.xml;
    format = "binary";
  };

  programs.azurevpnclient = {
    enable = true;
    profileFile = config.sops.secrets.azure-vpn-profile.path;
    profileName = "MSFT-AzVPN-TEST.xml";
    profileUsers = [ "joemo" ];
    softwareRendering = true;
    browser = "firefox"; # Open sign-in in Firefox inside WSL rather than Windows
  };

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

  # Force Firefox XWayland to fix broken context menus under native Wayland on WSL
  environment.variables.MOZ_ENABLE_WAYLAND = "0";
  environment.variables.MOZ_GTK_TITLEBAR_DECORATION = "client";

  networking.hostName = "wsl-work";
  time.timeZone = "America/Los_Angeles";

  system.stateVersion = "25.11";
}
