{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

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
      ...
    }:
    let
      toPath = path: ./. + path;

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

      mkSystem =
        {
          system-builder,
          home-manager-module,
          platform-modules,
          homePrefix,
          defaultSystem,
        }:
        host-name:
        {
          system ? defaultSystem,
          primaryUser ? "dylanj",
          system-modules ? [ (import (toPath "/hosts/${host-name}/configuration.nix")) ],
          user-modules ? [ (import (toPath "/hosts/${host-name}/home-manager.nix")) ],
        }:
        system-builder {
          inherit system;

          modules = system-modules ++ [
            home-manager-module
            overlays-module
            platform-modules
            (import ./modules/shared)
            {
              custom.primaryUser = primaryUser;
              custom.homePrefix = homePrefix;
              custom.userModules = user-modules;
            }
          ];

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
        home-manager-module = home-manager.darwinModules.home-manager;
        platform-modules = import ./modules/nix-darwin;
        homePrefix = "/Users";
        defaultSystem = "aarch64-darwin";
      });

      mkNixOS = builtins.mapAttrs (mkSystem {
        system-builder = nixpkgs.lib.nixosSystem;
        home-manager-module = home-manager.nixosModules.home-manager;
        platform-modules = import ./modules/nixos;
        homePrefix = "/home";
        defaultSystem = "x86_64-linux";
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
