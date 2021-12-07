{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, ... }: {
    nixosConfigurations."dylanj-work" = nixpkgs.lib.nixosSystem
      {
        system = "x86_64-linux";
        modules = [
          ./system
          home-manager.nixosModules.home-manager
        ];
      };
  };
}
