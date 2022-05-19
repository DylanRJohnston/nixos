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
  };

  outputs = { flake-utils, nixpkgs, darwin, home-manager, hardware, ... }:
    let
      toPath = path: ./. + path;

      lockfile = builtins.fromJSON (builtins.readFile ./flake.lock);

      mkSystem = { builder, home-manager }: host-name: system: builder {
        inherit system;

        specialArgs = {
          inherit lockfile hardware;
          common = import ./common/nixos;
        };

        modules = [
          home-manager
          (toPath "/hosts/${host-name}/modules")
          ({
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs.common = import (toPath "/common/home-manager");
            home-manager.users.dylanj = import (toPath "/hosts/${host-name}/home-manager");
          })
        ];
      };

      mkDarwin = mkSystem {
        builder = darwin.lib.darwinSystem;
        home-manager = home-manager.darwinModules.home-manager;
      };

      mkNixos = mkSystem {
        builder = nixpkgs.lib.nixosSystem;
        home-manager = home-manager.nixosModules.home-manager;
      };
    in
    {
      nixosConfigurations = builtins.mapAttrs mkNixos {
        "work-dell" = "x86_64-linux";
        "desktop" = "x86_64-linux";
        "ipad" = "aarch64-linux";
      };

      darwinConfigurations = builtins.mapAttrs mkDarwin {
        "macbook-pro" = "aarch64-darwin";
      };
    };
}
