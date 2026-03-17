{
  inputs.darwin.url = "github:lnl7/nix-darwin/master";
  inputs.darwin.inputs.nixpkgs.follows = "nixpkgs";

  inputs.den.url = "github:vic/den/v0.12.0";

  inputs.flake-aspects.url = "github:vic/flake-aspects/v0.7.0";

  inputs.hardware.url = "github:nixos/nixos-hardware";

  inputs.home-manager.url = "github:nix-community/home-manager/master";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.import-tree.url = "github:vic/import-tree";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs =
    inputs:
    (inputs.nixpkgs.lib.evalModules {
      specialArgs = { inherit inputs; };
      modules = [
        (inputs.import-tree [
          ./modules
          ./hosts
        ])
      ];
    }).config.flake;
}
