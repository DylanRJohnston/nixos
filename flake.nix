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

  outputs = { self, nixpkgs, darwin, home-manager, ... }:
    {
      nixosConfigurations = {
        "dylanj-work-dell" = mkSystem ./hosts/dylanj-work-dell;
        "dylanj-desktop" = mkSystem ./hosts/dylanj-desktop;
      };

      darwinConfigurations = {
        "macbook-pro" = import ./hosts/macbook-pro {
          inherit (darwin.lib) darwinSystem;
          inherit (home-manager.darwinModules) home-manager;
        };
      };
    };
}
