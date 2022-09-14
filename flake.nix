{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-22.05";
    hardware.url = "github:nixos/nixos-hardware";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/release-22.05";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, darwin, flake-utils, hardware, home-manager, nixpkgs, wsl }:
    let
      toPath = path: ./. + path;

      home-manager-config = { host-name, user }: ({
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.${user} = import (toPath "/hosts/${host-name}/home-manager.nix");
        home-manager.extraSpecialArgs.common = { }
          // (import ./common/home-manager)
          // (import ./common/scripts);
      });

      overlays-module = ({
        nixpkgs.overlays = [
          (import ./packages)
        ];
      });

      mkSystem = { system-builder, home-manager-module, common-modules }: host-name: { system, user ? "dylanj" }: system-builder {
        inherit system;

        specialArgs = {
          lockfile = builtins.fromJSON (builtins.readFile ./flake.lock);
          modules = {
            hardware = hardware.nixosModules;
            wsl = wsl.nixosModules.wsl;
          };

          common = { }
            // common-modules
            // (import ./common/shared)
            // (import ./common/scripts);
        };

        modules = [
          home-manager-module
          overlays-module
          (home-manager-config { inherit host-name user; })
          (toPath "/hosts/${host-name}/configuration.nix")
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

      pkgs = import nixpkgs {
        system = "aarch64-darwin";
        overlays = [
          (import ./packages)
          (import ./fixes)
        ];
      };
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
