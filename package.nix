{
  lib,
  src,
  rustPlatform,
  pkg-config,
  glib,
  glib-networking,
  gettext,
  wrapGAppsHook4,
  desktop-file-utils,
  gtk4,
  libadwaita,
  webkitgtk_6_0,
  poppler,
  openssl,
  wayland,
  shared-mime-info,
  gnupg,
  xdg-utils,
}:

rustPlatform.buildRustPackage {
  pname = "hylki";
  version = (lib.importTOML "${src}/Cargo.toml").package.version;

  inherit src;
  # Read from the source, which is a flake input and so already fetched at
  # evaluation time: a release bump needs no Cargo hash.
  cargoLock.lockFile = "${src}/Cargo.lock";

  nativeBuildInputs = [
    pkg-config
    glib
    gettext
    wrapGAppsHook4
    desktop-file-utils
  ];

  buildInputs = [
    glib-networking
    gtk4
    libadwaita
    webkitgtk_6_0
    poppler
    openssl
    wayland
  ];

  nativeCheckInputs = [ gnupg ];

  preCheck = ''
    export XDG_DATA_DIRS=${shared-mime-info}/share
  '';

  postInstall = ''
    app_id=co.hyprlab.Hylki

    for size in 256x256 512x512; do
      install -Dm644 data/icons/hicolor/$size/apps/$app_id.png \
        $out/share/icons/hicolor/$size/apps/$app_id.png
    done
    install -Dm644 data/icons/hicolor/scalable/apps/$app_id.svg \
      $out/share/icons/hicolor/scalable/apps/$app_id.svg
    install -Dm644 data/icons/hicolor/symbolic/apps/$app_id-symbolic.svg \
      $out/share/icons/hicolor/symbolic/apps/$app_id-symbolic.svg

    install -d $out/share/applications $out/share/metainfo
    msgfmt --desktop --template=data/$app_id.desktop -d po \
      -o $out/share/applications/$app_id.desktop
    msgfmt --xml --template=data/$app_id.metainfo.xml -d po \
      -o $out/share/metainfo/$app_id.metainfo.xml
    desktop-file-validate $out/share/applications/$app_id.desktop

    for po in po/*.po; do
      lang=$(basename "$po" .po)
      install -d $out/share/locale/$lang/LC_MESSAGES
      msgfmt -o $out/share/locale/$lang/LC_MESSAGES/hylki.mo "$po"
    done
  '';

  preFixup = ''
    gappsWrapperArgs+=(--prefix XDG_DATA_DIRS : ${shared-mime-info}/share)
    gappsWrapperArgs+=(--prefix PATH : ${
      lib.makeBinPath [
        gnupg
        xdg-utils
      ]
    })
  '';

  meta = {
    description = "Clean, fast GNOME-native email client";
    homepage = "https://hylki.hyprlab.co";
    license = lib.licenses.agpl3Plus;
    mainProgram = "hylki";
    platforms = lib.platforms.linux;
  };
}
