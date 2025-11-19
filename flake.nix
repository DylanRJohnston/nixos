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

      home-manager-config =
        {
          user,
          homeFormat,
          homeManagerModules,
        }:
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${user} = {
            imports = homeManagerModules;
          };
          users.users.${user}.home = homeFormat user;
          home-manager.extraSpecialArgs.common =
            { } # nix-fmt
            // (import ./common/home-manager)
            // (import ./common/scripts)
            // (import ./common/shared);
        };

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
          common-modules,
          homeFormat,
          defaultSystem,
          additionalModules ? (user: { }),
        }:
        host-name:
        {
          system ? defaultSystem,
          user ? "dylanj",
          homeManagerModules ? (import (toPath "/hosts/${host-name}/home-manager.nix")),
          systemModules ? (import (toPath "/hosts/${host-name}/configuration.nix")),
        }:
        system-builder {
          inherit system;

          specialArgs = {
            lockfile = builtins.fromJSON (builtins.readFile ./flake.lock);

            modules = {
              hardware = hardware.nixosModules;
              wsl = wsl.nixosModules.wsl;
              jovian = jovian.nixosModules.jovian;
              vscode-server = vscode-server.nixosModules.default;
              steam-compat = nix-gaming.nixosModules.steamCompat;
            };

            common =
              { } # nix-fmt
              // common-modules
              // (import ./common/shared)
              // (import ./common/scripts);
          };

          modules = [
            home-manager-module
            overlays-module
            (home-manager-config {
              inherit
                user
                homeFormat
                homeManagerModules
                ;
            })
            systemModules
            (additionalModules user)
          ];
        };

      mkDarwin = builtins.mapAttrs (mkSystem {
        system-builder = darwin.lib.darwinSystem;
        home-manager-module = home-manager.darwinModules.home-manager;
        common-modules = import ./common/nix-darwin;
        homeFormat = user: "/Users/${user}";
        defaultSystem = "aarch64-darwin";
        additionalModules = user: { system.primaryUser = user; };
      });

      mkNixOS = builtins.mapAttrs (mkSystem {
        system-builder = nixpkgs.lib.nixosSystem;
        home-manager-module = home-manager.nixosModules.home-manager;
        common-modules = import ./common/nixos;
        homeFormat = user: "/home/${user}";
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
        "MNM-L4G3HW02WK".user = "dylan.johnston";
      };

      templates = {
        basic = {
          path = ./templates/basic;
          description = "Basic dev env shell";
        };

        rust = {
          path = ./tempaltes/rust;
          description = "basic rust shell";
        };
      };
    };
}
