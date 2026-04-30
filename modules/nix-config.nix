let
  lockfile = builtins.fromJSON (builtins.readFile ../flake.lock);
in
{ unitTest, inputs, ... }:
{
  arc.base.os = {
    nixpkgs.config.allowUnfree = true;
    nix = {
      enable = true;
      extraOptions = "experimental-features = nix-command flakes pipe-operators";
      nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

      registry = {
        nixpkgs = {
          exact = false;
          from = {
            id = "nixpkgs";
            type = "indirect";
          };
          to = {
            owner = "NixOS";
            repo = "nixpkgs";
            type = "github";
            rev = lockfile.nodes.nixpkgs.locked.rev;
            narHash = lockfile.nodes.nixpkgs.locked.narHash;
          };
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
