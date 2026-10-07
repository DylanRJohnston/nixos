{
  inputs = {
    den.url = "github:denful/den/v0.19.0";
    import-tree.url = "github:vic/import-tree";

    # Trying to maximise binary cache hits
    nixpkgs.follows = "raspberry-pi/nixpkgs";

    darwin.url = "https://flakehub.com/f/nix-darwin/nix-darwin/0";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "https://flakehub.com/f/nix-community/home-manager/0";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    raspberry-pi.url = "github:nvmd/nixos-raspberrypi/develop";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
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

  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };
}
