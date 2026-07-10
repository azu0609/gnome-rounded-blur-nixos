# GNOME Rounded Blur on NixOS

A flake of [kancko/gnome-rounded-blur](https://github.com/kancko/gnome-rounded-blur) for NixOS.  
Refer to the original README for more info on what it is.

Add this repository to your system flake and make its `nixpkgs` input follow yours:

```nix
{
  inputs ={
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    gnome-rounded-blur = {
      url = "github:azu0609/gnome-rounded-blur-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, gnome-rounded-blur, ... }: {
    nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
      modules = [
        gnome-rounded-blur.nixosModules.default
        ({ pkgs, ... }: {
          services.gnome-rounded-blur.enable = true;
        })
      ];
    };
  };
}
```

The package and overlay are also available as `packages.<system>.default` and `overlays.default`, respectively.

> [!IMPORTANT]
> Using only `environment.systemPackages` is not enough for this library, as the NixOS module uses GNOME's `sessionPath` option to configure the runtime search paths.

## Mutter rounded corners (Wayland)

The module can also patch Mutter 50 so native Wayland application windows are
clipped to a 15px radius and receive the focused/unfocused shadow used by
libadwaita 1.9. Maximized, fullscreen, and tiled windows remain square. X11 and
Xwayland windows are unchanged.

```nix
services.gnome-rounded-blur.roundedCorners.enable = true;
```

This option is independent of `services.gnome-rounded-blur.enable`; enable both
when you want the rounded blur library and the compositor patch. Enabling it
rebuilds Mutter and GNOME Shell from the nixpkgs revision used by your system.
