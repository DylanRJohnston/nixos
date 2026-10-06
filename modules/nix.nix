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
    nixos = {
      imports = [ inputs.determinate.nixosModules.default ];
      nix.settings.trusted-users = [ "dylanj" ]; # TODO: Make this derived
    };

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

        determinateNixd = {
          builder.state = "enabled";
          garbageCollector.strategy = "automatic";
        };

        customSettings = {
          sandbox = true;

          trusted-users = [ "dylanj" ];
          extra-trusted-public-keys = [
            "nixbuild.net/dylan.r.johnston@gmail.com-1:UiRFFNl0XJovNJ0nLfIy+aUZno6HBXwo60Rdaw6C3Fs="
          ];

          experimental-features = [
            "nix-command"
            "flakes"
            "pipe-operators"
          ];
        };
      };
    };
  };

  flake.tests.nix-config.test-nixbuild-signing-key = unitTest (
    { arc, apple, ... }:
    {
      den.hosts.aarch64-darwin.apple.aspect.includes = with arc; [
        base
        determinate
      ];

      expr = apple.determinateNix.customSettings.extra-trusted-public-keys;
      expected = [
        "nixbuild.net/dylan.r.johnston@gmail.com-1:UiRFFNl0XJovNJ0nLfIy+aUZno6HBXwo60Rdaw6C3Fs="
      ];
    }
  );

  flake.tests.nix-config.test-duplicate-substituter = unitTest (
    { arc, igloo, ... }:
    {
      den.hosts.x86_64-linux.igloo = {
        users.tux = { };
        aspect.includes = with arc; [ base ];
      };

      expr = igloo.nix.nixPath;
      expected = [
        "nixpkgs=${inputs.nixpkgs}"
      ];
    }
  );
}
