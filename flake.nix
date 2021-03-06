{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    hardware.url = "github:nixos/nixos-hardware";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, flake-utils, nixpkgs, darwin, home-manager, hardware, fenix }:
    let
      toPath = path: ./. + path;

      lockfile = builtins.fromJSON (builtins.readFile ./flake.lock);

      packages-overlays = import ./packages/overlay.nix;

      mkMerge = nixpkgs.lib.mkMerge;

      home-manager-config = { host-name, user }: ({
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.${user} = import (toPath "/hosts/${host-name}/home-manager.nix");
        home-manager.extraSpecialArgs.common = { }
          // (import ./common/home-manager)
          // (import ./common/scripts);
      });

      mkSystem = { system-builder, home-manager-module, common-modules }: host-name: { system, user ? "dylanj" }: system-builder {
        inherit system;

        specialArgs = {
          inherit lockfile hardware;

          common = { }
            // common-modules
            // (import ./common/shared)
            // (import ./common/scripts);
        };

        modules = [
          ({ nixpkgs.overlays = [ fenix.overlay packages-overlays ]; })
          (toPath "/hosts/${host-name}/configuration.nix")
          home-manager-module
          (home-manager-config { inherit host-name user; })
        ];
      };

      mkDarwin = builtins.mapAttrs (mkSystem {
        system-builder = darwin.lib.darwinSystem;
        home-manager-module = home-manager.darwinModules.home-manager;
        common-modules = import ./common/nix-darwin;
      });

      mkNixOS = builtins.mapAttrs (mkSystem {
        system-builder = nixpkgs.lib.nixosSystem;
        home-manager-module = home-manager.nixosModules.home-manager;
        common-modules = import ./common/nixos;
      });
    in
    {
      nixosConfigurations = mkNixOS {
        "work-dell".system = "x86_64-linux";
        "desktop".system = "x86_64-linux";
        "ipad".system = "aarch64-linux";
      };

      darwinConfigurations = mkDarwin {
        "macbook-pro".system = "x86_64-darwin";
        "AU-L-0226" = {
          system = "aarch64-darwin";
          user = "dylanjohnston";
        };
      };

      templates = {
        basic = {
          path = ./templates/basic;
          description = "Basic dev env shell";
        };
      };
    };
}
