{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.gnome-rounded-blur;
in
{
  options.services.gnome-rounded-blur = {
    enable = lib.mkEnableOption "rounded dynamic blur support for GNOME Shell extensions";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./package.nix { };
      defaultText = lib.literalExpression "pkgs.callPackage ./package.nix { }";
      description = "The GNOME Rounded Blur package to expose to GNOME Shell.";
    };

    roundedCorners.enable = lib.mkEnableOption ''
      the Mutter 50 Wayland patch for 15px window corners and libadwaita-style shadows
    '';
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.desktopManager.gnome.sessionPath = [ cfg.package ];
    })

    (lib.mkIf cfg.roundedCorners.enable {
      assertions = [
        {
          assertion = lib.versions.major pkgs.mutter.version == "50";
          message = ''
            services.gnome-rounded-blur.roundedCorners.enable targets Mutter 50,
            but this nixpkgs provides Mutter ${pkgs.mutter.version}.
          '';
        }
      ];

      nixpkgs.overlays = [
        (_final: prev: {
          mutter = prev.mutter.overrideAttrs (old: {
            patches = (old.patches or [ ]) ++ [
              ./patches/mutter-50-rounded-corners.patch
            ];
          });
        })
      ];
    })
  ];
}
