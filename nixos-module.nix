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
  };

  config = lib.mkIf cfg.enable {
    services.desktopManager.gnome.sessionPath = [ cfg.package ];
  };
}
