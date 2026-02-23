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
      options.custom.homeModule = lib.mkOption {
        type = lib.types.listOf lib.types.deferredModule;
      };
      config = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.${config.custom.primaryUser} = {
          imports = config.custom.homeModule;
          home.stateVersion = "26.05";
        };
      };
    };
}
