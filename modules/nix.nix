{
  unitTest,
  inputs,
  lib,
  ...
}:
let
  registry = {
    nixpkgs = {
      exact = true;
      from = {
        id = "nixpkgs";
        type = "indirect";
      };
      to =
        let
          lockfile = builtins.fromJSON (builtins.readFile ../flake.lock);
        in
        {
          owner = "NixOS";
          repo = "nixpkgs";
          type = "github";
          rev = lockfile.nodes.nixpkgs.locked.rev;
          narHash = lockfile.nodes.nixpkgs.locked.narHash;
        };
    };
  };
in
{
  arc.base.os = {
    nixpkgs.config.allowUnfree = true;
    nix = {
      enable = true;
      inherit registry;

      extraOptions = "experimental-features = nix-command flakes pipe-operators";
      nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

    };
  };

  arc.determinate = {
    nixos.imports = [ inputs.determinate.nixosModules.default ];
    os.homeManager = {
      imports = [ inputs.determinate.homeManagerModules.default ];
      nix.package = lib.mkForce null;
    };

    # It's annoying that the nix and darwin modules for determinate are so different
    darwin = {
      imports = [ inputs.determinate.darwinModules.default ];
      nix.enable = lib.mkForce false;

      determinateNix = {
        enable = true;
        inherit registry;

        customSettings = {
          sandbox = true;

          experimental-features = [
            "nix-command"
            "flakes"
            "pipe-operators"
          ];
        };
      };
    };
  };

  flake.tests.nix-config.test-duplicate-substituter = unitTest (
    { arc, igloo, ... }:
    {
      den.hosts.x86_64-linux.igloo = {
        users.tux = { };
        aspects = with arc; [ base ];
      };

      expr = igloo.nix.nixPath;
      expected = [
        "nixpkgs=${inputs.nixpkgs}"
      ];
    }
  );
}
