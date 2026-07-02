{
  lib,
  stdenv,
  meson,
  ninja,
  pkg-config,
  gobject-introspection,
  glib,
  mutter,
  fetchFromGitHub,
}:

let
  version = "1.0.0-unstable-2026-04-08";
  rev = "9c7efb7ac5de60fee47ae403753e54319e839f03";

  mutterMajor = lib.versions.major mutter.version;
  mutterApiVersion =
    mutter.libmutter_api_version or (toString ((builtins.fromJSON mutterMajor) - 32));
  mutterLibdir = mutter.libdir or "${mutter}/lib/mutter-${mutterApiVersion}";
in
stdenv.mkDerivation {
  pname = "gnome-rounded-blur";
  inherit version;

  src = fetchFromGitHub {
    owner = "kancko";
    repo = "gnome-rounded-blur";
    inherit rev;
    hash = "sha256-hiWQaYydlyIMHKsx49f7sGOLM9ev1g1kdlloUszZU8I=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
  ];

  # Mutter's pkg-config files reference its full build dependency set, but the
  # package intentionally does not propagate most of those development
  # outputs. Reuse that set so this remains in sync as Mutter's API changes.
  buildInputs = [
    glib
    mutter
  ]
  ++ (mutter.buildInputs or [ ])
  ++ (mutter.propagatedBuildInputs or [ ]);

  postPatch = ''
    sed -E -i \
      -e "s/^mutter_api_version = .*/mutter_api_version = '${mutterApiVersion}'/" \
      -e "s/^mutter_req = .*/mutter_req = '>= ${mutterMajor}.0'/" \
      -e "s/dependency\('libmutter-[0-9]+'\)/dependency('libmutter-${mutterApiVersion}')/" \
      meson.build

    grep -F "mutter_api_version = '${mutterApiVersion}'" meson.build
    grep -F "mutter_req = '>= ${mutterMajor}.0'" meson.build
    grep -F "dependency('libmutter-${mutterApiVersion}')" meson.build
  '';

  postFixup = ''
    patchelf --add-rpath "${mutterLibdir}" "$out/lib/libblur-effect-1.0.so.1.0.0"
  '';

  strictDeps = true;

  meta = {
    description = "Blur.BlurEffect with corner-radius support for GNOME Shell extensions";
    homepage = "https://github.com/kancko/gnome-rounded-blur";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
  };
}
