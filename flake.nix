{
  inputs = {
    darwin = {
      url = "https://flakehub.com/f/nix-darwin/nix-darwin/0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    den.url = "github:dylanrjohnston/den/dylan.johnston/strict-mode";

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";

    hardware.url = "github:nixos/nixos-hardware";

    home-manager = {
      url = "https://flakehub.com/f/nix-community/home-manager/0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    import-tree.url = "github:vic/import-tree";

    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
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
