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

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { flake-utils, nixpkgs, darwin, home-manager, hardware, fenix, ... }:
    let
      toPath = path: ./. + path;

      lockfile = builtins.fromJSON (builtins.readFile ./flake.lock);

      custom-packages-overlay = import ./packages/overlay.nix;

      overlays = {
        nixpkgs.overlays = [ fenix.overlay custom-packages-overlay ];
      };

      mkSystem = { builder, home-manager, common }: host-name: { system, user ? "dylanj" }: builder {
        inherit system;

        specialArgs = {
          inherit lockfile hardware;
          common = (import ./common/shared) // common // (import ./common/scripts);
        };

        modules = [
          overlays
          home-manager
          (toPath "/hosts/${host-name}/configuration.nix")
          ({
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs.common = import (toPath "/common/home-manager") // (import ./common/scripts);
            home-manager.users.${user} = import (toPath "/hosts/${host-name}/home-manager.nix");
          })
        ];
      };

      mkDarwin = mkSystem {
        builder = darwin.lib.darwinSystem;
        home-manager = home-manager.darwinModules.home-manager;
        common = import ./common/nix-darwin;
      };

      mkNixOS = mkSystem {
        builder = nixpkgs.lib.nixosSystem;
        home-manager = home-manager.nixosModules.home-manager;
        common = import ./common/nixos;
      };
    in
    {
      nixosConfigurations = builtins.mapAttrs mkNixOS {
        "work-dell" = { system = "x86_64-linux"; };
        "desktop" = { system = "x86_64-linux"; };
        "ipad" = { system = "aarch64-linux"; };
      };

      darwinConfigurations = builtins.mapAttrs mkDarwin {
        "macbook-pro" = { system = "x86_64-darwin"; };
        "AU-L-0226" = { system = "aarch64-darwin"; user = "dylanjohnston"; };
      };

      templates = {
        basic = {
          path = ./templates/basic;
          description = "Basic dev env shell";
        };
      };
    };
}
