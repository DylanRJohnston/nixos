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
      lockfile = builtins.fromJSON (builtins.readFile ./flake.lock);

      toPath = path: ./. + path;

      home-manager-module = host-name: [{
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs.common = import ./common/home-manager;
        home-manager.users.dylanj = import (toPath "/hosts/${host-name}/home-manager");
      }];

      host-modules = host-name: [ (toPath "/hosts/${host-name}/modules") ];

      mkSystem = { builder, extra-modules }: host-name: system: builder {
        inherit system;

        specialArgs = {
          inherit lockfile hardware;
          common = import ./common/nixos;
        };

        modules = extra-modules ++ (host-modules host-name) ++ (home-manager-module host-name);
      };

      mkDarwin = mkSystem {
        builder = darwin.lib.darwinSystem;
        extra-modules = [ home-manager.darwinModules.home-manager ];
      };

      mkNixos = mkSystem {
        builder = nixpkgs.lib.nixosSystem;
        extra-modules = [ home-manager.nixosModules.home-manager ];
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
