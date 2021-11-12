{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    impermanence.url = "github:RiscadoA/impermanence";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, impermanence, ... }: {
    nixosConfigurations."dylanj-work" = nixpkgs.lib.nixosSystem
      {
        system = "x86_64-linux";
        modules = [
          ./system
          impermanence.nixosModules.impermanence
          home-manager.nixosModules.home-manager
          ./home-manager
        ];
        specialArgs = { inherit impermanence; };
      };
  };
}
