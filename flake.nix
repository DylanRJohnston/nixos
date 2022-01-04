{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nix, nixpkgs, flake-utils, home-manager, ... }:

    {
      nixosConfigurations."dylanj-work" = nixpkgs.lib.nixosSystem
        {
          system = "x86_64-linux";
          modules = [
            ./system
            home-manager.nixosModules.home-manager
            ./dylanj
          ];
        };
    };
}
