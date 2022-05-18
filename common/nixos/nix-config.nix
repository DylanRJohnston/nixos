{ pkgs, inputs, ... }: {
  nixpkgs.config.allowUnfree = true;
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";

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
          rev = inputs.nixpkgs.rev;
          narHash = inputs.nixpkgs.narHash;
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
          rev = inputs.flake-utils.rev;
          narHash = inputs.flake-utils.narHash;
        };
      };
    };
  };
}
