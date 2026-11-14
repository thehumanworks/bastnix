{
  description = "Nix package, Home Manager module and NixOS module for Bast (https://bast.sh)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f: lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: rec {
        bast = pkgs.callPackage ./nix/package.nix { };
        default = bast;
      });

      overlays.default = final: _prev: {
        bast = final.callPackage ./nix/package.nix { };
      };

      homeManagerModules = rec {
        bast = ./nix/home-manager.nix;
        default = bast;
      };
      homeModules = self.homeManagerModules;

      nixosModules = rec {
        bast = ./nix/nixos.nix;
        default = bast;
      };

      checks = forAllSystems (pkgs: {
        inherit (self.packages.${pkgs.stdenv.hostPlatform.system}) bast;
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt);
    };
}
