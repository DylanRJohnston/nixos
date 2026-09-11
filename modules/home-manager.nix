{
  inputs,
  lib,
  unitTest,
  ...
}:
{
  arc.base = rec {
    includes = [
      _.homeManager
    ];

    _.homeManager = {
      nixos.imports = [ inputs.home-manager.nixosModules.home-manager ];
      darwin.imports = [ inputs.home-manager.darwinModules.home-manager ];

      os = {
        options.homeManager = lib.mkOption {
          type = lib.types.deferredModule;
        };

        config = {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        };
      };

      homeManager =
        { osConfig, ... }:
        {
          imports = [ osConfig.homeManager ];

          home.stateVersion = "26.05";

          # Work around https://github.com/nix-community/home-manager/issues/7935.
          manual.manpages.enable = false;
        };
    };
  };

  flake.tests.home-manager.test-disable-manpages = unitTest (
    { arc, igloo, ... }:
    {
      den.hosts.x86_64-linux.igloo = {
        users.tux = { };
        aspects = [ arc.base ];
      };

      expr = igloo.home-manager.users.tux.manual.manpages.enable;
      expected = false;
    }
  );
}
