{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    hardware.url = "github:nixos/nixos-hardware";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/3.15.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      darwin,
      hardware,
      home-manager,
      nixpkgs,
      determinate,
      ...
    }:
    let
      overlays-module =
        let
          package-overlay = import ./packages;
        in
        {
          nixpkgs.overlays = [
            package-overlay
          ];
        };

      sharedModules = [
        overlays-module
        (import ./modules/shared)
      ];

      mkSystem =
        {
          system-builder,
          platformSpecificSystemModules,
          homePrefix,
          defaultSystem,
        }:
        host-name:
        {
          system ? defaultSystem,
          primaryUser ? "dylanj",
          system-modules ? [ (import (./. + "/hosts/${host-name}/configuration.nix")) ],
          user-modules ? [ (import (./. + "/hosts/${host-name}/home-manager.nix")) ],
        }:
        let
          machineSpecificSystemModules = system-modules;
          userSpecificHomeManagerModules = [
            {
              custom.primaryUser = primaryUser;
              custom.homePrefix = homePrefix;
              custom.userModules = user-modules;
            }
          ];
        in
        system-builder {
          inherit system;

          modules =
            platformSpecificSystemModules
            ++ machineSpecificSystemModules
            ++ userSpecificHomeManagerModules
            ++ sharedModules;

          specialArgs = {
            lockfile = builtins.fromJSON (builtins.readFile ./flake.lock);

            modules = {
              hardware = hardware.nixosModules;
            };
          };

        };

      mkDarwin = builtins.mapAttrs (mkSystem {
        system-builder = darwin.lib.darwinSystem;
        defaultSystem = "aarch64-darwin";
        homePrefix = "/Users";
        platformSpecificSystemModules = [
          determinate.darwinModules.default
          home-manager.darwinModules.home-manager
          (import ./modules/nix-darwin)
        ];
      });

      mkNixOS = builtins.mapAttrs (mkSystem {
        system-builder = nixpkgs.lib.nixosSystem;
        defaultSystem = "x86_64-linux";
        homePrefix = "/home";
        platformSpecificSystemModules = [
          determinate.nixosModules.default
          home-manager.nixosModules.home-manager
          (import ./modules/nixos)
        ];
      });
    in
    {
      inherit mkNixOS mkDarwin;

      nixosConfigurations = mkNixOS {
        "work-dell".system = "x86_64-linux";
        "desktop".system = "x86_64-linux";
        "ipad".system = "aarch64-linux";
        "steamdeck".system = "x86_64-linux";
      };

      darwinConfigurations = mkDarwin {
        "macbook-pro".system = "aarch64-darwin";
      };
    };
}
