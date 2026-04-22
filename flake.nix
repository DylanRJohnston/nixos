{
  inputs.darwin.url = "github:lnl7/nix-darwin/master";
  inputs.darwin.inputs.nixpkgs.follows = "nixpkgs";

  inputs.den.url = "github:dylanrjohnston/den/dylan.johnston/strict-mode";

  inputs.hardware.url = "github:nixos/nixos-hardware";

  inputs.home-manager.url = "github:nix-community/home-manager/master";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.import-tree.url = "github:vic/import-tree";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  # inputs.beads.url = "github:gastownhall/beads/v1.0.2";
  # inputs.beads.inputs.nixpkgs.follows = "nixpkgs";

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
