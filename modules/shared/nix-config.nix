{
  pkgs,
  lockfile,
  lib,
  ...
}:
{
  options.custom.nix-config.enable = lib.mkEnableOption "Enable nix-config";

  config = {
    nixpkgs.config.allowUnfree = true;
    nix = {
      package = pkgs.nixVersions.stable;
      extraOptions = "experimental-features = nix-command flakes";

      settings = {
        substituters = [ "https://aseipp-nix-cache.freetls.fastly.net" ];
      };

      registry = {
        nixpkgs = {
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
        flake-util = {
          from = {
            id = "flake-utils";
            type = "indirect";
          };
          to = {
            owner = "numtide";
            repo = "flake-utils";
            type = "github";
            rev = lockfile.nodes.flake-utils.locked.rev;
            narHash = lockfile.nodes.flake-utils.locked.narHash;
          };
        };
      };
    };
  };
}
