{ inputs, lib, ... }:
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
        };
    };
  };
}
