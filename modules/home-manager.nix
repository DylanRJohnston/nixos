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
  ];

  kit.base._.homeManager = {
    includes = [
      kit.base._.homeManager._.globalModule
    ];

    homeManager.home.stateVersion = "26.05";

    nixos.imports = [ inputs.home-manager.nixosModules.home-manager ];
    darwin.imports = [ inputs.home-manager.darwinModules.home-manager ];

    os.config = {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
    };

    _.globalModule =
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
      };
  };
}
