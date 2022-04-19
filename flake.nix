{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, darwin, home-manager }:
    let
      toPath = path: ./. + path;

      mkSystem = { builder, home-manager }: name: system: builder {
        inherit system;
        specialArgs.common = import ./common/nixos;
        modules = [
          home-manager
          (toPath "/hosts/${name}/modules")
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs.common = import ./common/home-manager;
            home-manager.users.dylanj = import (toPath "/hosts/${name}/home-manager");
          }
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
      };

      darwinConfigurations = builtins.mapAttrs mkDarwin {
        "macbook-pro" = "aarch64-darwin";
      };
    };
}
