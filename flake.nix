{
  inputs = {
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    den.url = "github:dylanrjohnston/den/dylan.johnston/strict-mode";

    determinate.url = "github:DeterminateSystems/determinate";
    determinate.inputs.nixpkgs.follows = "nixpkgs";

    hardware.url = "github:nixos/nixos-hardware";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    import-tree.url = "github:vic/import-tree";

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

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
