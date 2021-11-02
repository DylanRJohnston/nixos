{
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, home-manager, flake-utils, ... }: {
    nixosConfigurations."dylanj-fugro-dell" = nixpkgs.lib.nixosSystem
      {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.dylanj = import ./home;
          }
        ];
      };
  };
}
