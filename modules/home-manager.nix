{
  kit,
  inputs,
  lib,
  ...
}:
{
  kit.schema.user.classes = lib.mkDefault [ "homeManager" ];

  kit.base.includes = [
    kit.base._.homeManager
    kit.base._.homeManager._.hostConfig
  ];

  kit.base._.homeManager = {
    description = 22;

    homeManager.home.stateVersion = "26.05";

    nixos.imports = [ inputs.home-manager.nixosModules.home-manager ];
    darwin.imports = [ inputs.home-manager.darwinModules.home-manager ];

    os = {
      config = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      };
    };
  };

  kit.base._.homeManager._.hostConfig = (
    { user, ... }:
    {
      os =
        { config, ... }:
        {
          options.homeManager = lib.mkOption {
            type = lib.types.deferredModule;
          };

          config.home-manager.users.${user.userName}.imports = [ config.homeManager ];
        };
    }
  );

}
