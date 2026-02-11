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

    wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/3.15.2";
    };
  };

  outputs =
    {
      darwin,
      hardware,
      home-manager,
      nixpkgs,
      nix-gaming,
      wsl,
      jovian,
      vscode-server,
      determinate,
      ...
    }:
    let
      overlays-module =
        let
          package-overlay = import ./packages;
          proton-ge = final: prev: { proton-ge = nix-gaming.packages.${prev.system}.proton-ge; };
        in
        {
          nixpkgs.overlays = [
            package-overlay
            proton-ge
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
              wsl = wsl.nixosModules.wsl;
              jovian = jovian.nixosModules.jovian;
              vscode-server = vscode-server.nixosModules.default;
              steam-compat = nix-gaming.nixosModules.steamCompat;
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
