{
  unitTest,
  inputs,
  lib,
  ...
}:
let
  registry = {
    nixpkgs = {
      exact = false;
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
    os = {
      nix.enable = lib.mkForce false;
      homeManager.imports = [ inputs.determinate.homeManagerModules.default ];

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

    darwin.imports = [ inputs.determinate.darwinModules.default ];
    nixos.imports = [ inputs.determinate.nixosModules.default ];
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
