{ pkgs, ... }:

let
  setfacl = "${pkgs.acl}/bin/setfacl";
  xhost = "${pkgs.xhost}/bin/xhost";

  # Wrapper that forwards display/audio sockets and runs steam as the steam user.
  # Installed as a bin package so it's available in PATH at a stable location.
  steam-session = pkgs.writeShellScriptBin "steam-session" ''
    CALLER_RUNTIME="$XDG_RUNTIME_DIR"
    STEAM_RUNTIME="/run/user/$(id -u steam)"

    # If steam's runtime dir doesn't exist yet (before first reboot with
    # linger enabled), create a fallback under steam's home (visible inside
    # bwrap sandbox, unlike /tmp which is replaced with a fresh tmpfs)
    if [ ! -d "$STEAM_RUNTIME" ]; then
      STEAM_RUNTIME="/home/steam/.local/run"
      sudo -u steam mkdir -p "$STEAM_RUNTIME"
      sudo -u steam chmod 700 "$STEAM_RUNTIME"
    fi

    # Grant steam user traversal on the caller's runtime directory
    ${setfacl} -m u:steam:x "$CALLER_RUNTIME"

    # Wayland display socket
    [ -e "$CALLER_RUNTIME/$WAYLAND_DISPLAY" ] && \
      ${setfacl} -m u:steam:rw "$CALLER_RUNTIME/$WAYLAND_DISPLAY"

    # PipeWire socket for audio
    [ -e "$CALLER_RUNTIME/pipewire-0" ] && \
      ${setfacl} -m u:steam:rw "$CALLER_RUNTIME/pipewire-0"

    # PulseAudio socket (PipeWire compat layer, used by Steam)
    [ -d "$CALLER_RUNTIME/pulse" ] && \
      ${setfacl} -m u:steam:x "$CALLER_RUNTIME/pulse" && \
      ${setfacl} -m u:steam:rw "$CALLER_RUNTIME/pulse/native"

    # Symlink display and audio sockets into steam's runtime directory
    sudo -u steam ln -sf "$CALLER_RUNTIME/$WAYLAND_DISPLAY" "$STEAM_RUNTIME/$WAYLAND_DISPLAY" 2>/dev/null
    sudo -u steam ln -sf "$CALLER_RUNTIME/pipewire-0" "$STEAM_RUNTIME/pipewire-0" 2>/dev/null
    sudo -u steam mkdir -p "$STEAM_RUNTIME/pulse" 2>/dev/null
    sudo -u steam ln -sf "$CALLER_RUNTIME/pulse/native" "$STEAM_RUNTIME/pulse/native" 2>/dev/null

    # Grant steam user access to XWayland display (Steam's UI uses X11)
    ${xhost} +SI:localuser:steam

    # Revoke X11 access when we exit (whether Steam exits normally or crashes)
    cleanup() { ${xhost} -SI:localuser:steam 2>/dev/null; }
    trap cleanup EXIT

    # Ensure cwd is accessible to the steam user (bwrap inherits it)
    cd /
    # Run Steam as the steam user with its own runtime directory
    sudo -u steam env \
      HOME=/home/steam \
      XDG_RUNTIME_DIR="$STEAM_RUNTIME" \
      WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
      DISPLAY="$DISPLAY" \
      steam "$@"
  '';

  # Override Steam's .desktop file to use the wrapper
  steam-desktop = pkgs.makeDesktopItem {
    name = "steam";
    desktopName = "Steam";
    comment = "Application for managing and playing games on Steam";
    icon = "steam";
    exec = "steam-session %U";
    categories = [ "Network" "FileTransfer" "Game" ];
    mimeTypes = [ "x-scheme-handler/steam" "x-scheme-handler/steamlink" ];
  };
in
{
  # Dedicated user for Steam/games
  users.users.steam = {
    isNormalUser = true;
    description = "Steam";
    home = "/home/steam";
    extraGroups = [ "video" "audio" "input" ];
    packages = with pkgs; [
      mangohud
      protonup-qt
    ];
  };

  # Enable lingering so systemd creates /run/user/<steam-uid> at boot
  systemd.tmpfiles.rules = [
    "f /var/lib/systemd/linger/steam"
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
  programs.gamemode.enable = true;

  environment.systemPackages = [ steam-session steam-desktop ];
}
