{
  inputs,
  lib,
  ...
}:
{
  kit.schema.user.classes = lib.mkDefault [ "homeManager" ];

  kit.base = lib.debug.traceSeq "kit.base home manager module evaluated" {
    homeManager.home.stateVersion = "26.05";

    nixos.imports = [ inputs.home-manager.nixosModules.home-manager ];
    darwin.imports = [ inputs.home-manager.darwinModules.home-manager ];

    os = lib.debug.traceSeq "os home manager module evaluated" {
      options.homeManager = lib.mkOption {
        type = lib.types.deferredModule;
      };

      config = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      };
    };

    includes = [
      (
        { host, user }:
        lib.debug.traceSeq "!!!!!!!!!!! home manager module ${host.name} ${host.class} ${user.userName}" {
          os = lib.debug.traceSeq "0000000000 class accessed ${host.class}" (
            { config, ... }:
            lib.debug.traceSeq "----------- actual import" {
              home-manager.users.${user.userName}.imports = [
                config.homeManager
              ];
            }
          );
        }
      )
    ];
  };
}
