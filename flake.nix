{
  description = "Hylki, a GNOME-native email client";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # The packaged release. CI moves this tag to each new upstream release
    # once it builds and passes its tests.
    hylki-src = {
      url = "github:hyprlab/hylki/v1.46.1";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      hylki-src,
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    {
      packages = forAllSystems (system: {
        hylki = nixpkgs.legacyPackages.${system}.callPackage ./package.nix { src = hylki-src; };
        default = self.packages.${system}.hylki;
      });

      checks = forAllSystems (system: {
        inherit (self.packages.${system}) hylki;
      });
    };
}
