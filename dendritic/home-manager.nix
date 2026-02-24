{
  inputs,
  lib,
  ...
}:
{
  flake.modules.nixos.base = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];
  };

  flake.modules.darwin.base = {
    imports = [ inputs.home-manager.darwinModules.home-manager ];
  };

  flake.modules.generic.base =
    { config, ... }:
    {
      options.home = lib.mkOption {
        type = lib.types.deferredModule;
      };

      config = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.${config.system.primaryUser} = {
          imports = [ config.home ];
          home.stateVersion = "26.05";
        };
      };
    };
}
