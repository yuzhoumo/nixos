{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  runCommandCC,
  atk,
  cairo,
  curl,
  fontconfig,
  freetype,
  glib,
  gtk3,
  harfbuzz,
  libcap,
  libepoxy,
  libsecret,
  openssl,
  pango,
  sqlite,
  systemd,
  zenity,
  xdg-utils,
  zlib,
}:

let
  pname = "microsoft-azurevpnclient";
  version = "3.0.0";

  # LD_PRELOAD library that drops capabilities in non-VPN subprocesses.
  # Fixes AAD browser auth by allowing xdg-desktop-portal to identify callers.
  relax = runCommandCC "azurevpnclient-relax" { } ''
    mkdir -p $out/lib
    cc -O2 -Wall -shared -fPIC -nostartfiles \
      -o $out/lib/libazurevpnclient-relax.so \
      ${./relax.c}
  '';

  runtimeLibs = [
    atk
    cairo
    curl
    fontconfig
    freetype
    glib
    gtk3
    harfbuzz
    libcap
    libepoxy
    libsecret
    openssl
    pango
    sqlite
    stdenv.cc.cc.lib
    systemd
    zlib
  ];

  base = stdenv.mkDerivation {
    inherit pname version;

    src = fetchurl {
      url = "https://packages.microsoft.com/ubuntu/22.04/prod/pool/main/m/${pname}/${pname}_${version}_amd64.deb";
      hash = "sha256-nl02BDPR03TZoQUbspplED6BynTr6qNRVdHw6fyUV3s=";
    };

    nativeBuildInputs = [
      dpkg
      autoPatchelfHook
      makeWrapper
    ];

    buildInputs = runtimeLibs;

    unpackPhase = ''
      dpkg-deb -x $src .
    '';

    installPhase = ''
      mkdir -p $out/bin

      install -d $out/opt/microsoft/${pname}
      cp -r opt/microsoft/${pname}/* $out/opt/microsoft/${pname}/

      patchelf --set-rpath "${lib.makeLibraryPath runtimeLibs}:$out/opt/microsoft/${pname}/lib" \
        $out/opt/microsoft/${pname}/${pname}

      makeWrapper $out/opt/microsoft/${pname}/${pname} \
        $out/bin/azurevpnclient-unprivileged \
        --set GTK_USE_PORTAL 1 \
        --set LD_PRELOAD "${relax}/lib/libazurevpnclient-relax.so" \
        --prefix PATH : "${lib.makeBinPath [ zenity xdg-utils ]}" \
        --prefix LD_LIBRARY_PATH : "$out/opt/microsoft/${pname}/lib"

      install -Dm644 usr/share/icons/${pname}.png \
        $out/share/icons/hicolor/512x512/apps/${pname}.png

      install -Dm644 /dev/stdin $out/share/applications/${pname}.desktop <<EOF
[Desktop Entry]
Name=Azure VPN Client
Exec=azurevpnclient
Icon=microsoft-azurevpnclient
Type=Application
Categories=Network;
StartupNotify=true
StartupWMClass=${pname}
EOF
    '';

    meta = with lib; {
      description = "Microsoft Azure VPN Client for Linux";
      homepage = "https://learn.microsoft.com/en-us/azure/vpn-gateway/point-to-site-entra-vpn-client-linux";
      license = licenses.unfree;
      platforms = [ "x86_64-linux" ];
    };
  };

in base
