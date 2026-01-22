{
  lib,
  config,
  ...
}:
{
  options = {
    custom.userModules = lib.mkOption {
      type = lib.types.listOf lib.types.deferredModule;
      description = "List of home-manager modules to import";
    };
  };

  config = {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.${config.custom.primaryUser} = {
      imports = config.custom.userModules ++ [ ../home-manager ];
      home.stateVersion = "25.11";
    };

  };
}
