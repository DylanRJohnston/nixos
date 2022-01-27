{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, ... }:
    {
      nixosConfigurations = {
        "dylanj-work-dell" = import ./hosts/dylanj-work-dell {
          inherit (nixpkgs.lib) nixosSystem;
          inherit (home-manager.nixosModules) home-manager;
        };
      };
    };
}
