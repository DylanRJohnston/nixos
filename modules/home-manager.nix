{
  inputs,
  lib,
  ...
}:
{
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];
  den.default.homeManager.home.stateVersion = "26.05";

  den.aspects.base = {
    nixos.imports = [ inputs.home-manager.nixosModules.home-manager ];
    darwin.imports = [ inputs.home-manager.darwinModules.home-manager ];

    os =
      { config, ... }:
      {
        options.homeManager = lib.mkOption {
          type = lib.types.deferredModule;
        };

        config = {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${config.system.primaryUser}.imports = [ config.homeManager ];
        };
      };
  };
}
