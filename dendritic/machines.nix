{
  inputs,
  lib,
  config,
  ...
}:
let
  mkOptions =
    system:
    lib.mkOption {
      type = lib.types.lazyAttrsOf (
        lib.types.submodule {
          options = {
            system = lib.mkOption {
              type = lib.types.enum system;
            };

            roles = lib.mkOption {
              type = lib.types.listOf (
                lib.types.enum [
                  "base"
                  "development"
                  "entertainment"
                  "gaming"
                  "home-automation"
                ]
              );
            };

            module = lib.mkOption {
              type = lib.types.deferredModule;
            };

            homeManager = lib.mkOption {
              type = lib.types.deferredModule;
            };
          };
        }
      );
    };

  mkConfigurations =
    {
      configurations,
      systemBuilder,
      platformModules,
    }:
    lib.flip lib.mapAttrs configurations (
      name:
      {
        module,
        system,
        homeManager,
        roles,
      }:
      systemBuilder {
        modules = [
          {
            nixpkgs.hostPlatform = system;

            custom.homeModule = [
              homeManager
            ]
            ++ lib.map (role: config.flake.modules.homeManager.${role} or { }) roles;
          }

          module
        ]
        ++ lib.map (role: platformModules.${role} or { }) roles
        ++ lib.map (role: config.flake.modules.generic.${role} or { }) roles;
      }
    );

  mkChecks =
    platform: configurations:
    configurations
    |> lib.mapAttrsToList (
      name: machine: {
        ${machine.config.nixpkgs.hostPlatform.system} = {
          "configurations:${platform}:${name}" = machine.config.system.build.toplevel;
        };
      }
    )
    |> lib.mkMerge;
in
{
  imports = [
    inputs.darwin.flakeModules.default
  ];

  options.configurations.darwin = mkOptions [
    "x86_64-darwin"
    "aarch64-darwin"
  ];

  options.configurations.nixos = mkOptions [
    "x86_64-linux"
    "aarch64-linux"
  ];

  config.flake = {
    darwinConfigurations = mkConfigurations {
      configurations = config.configurations.darwin;
      systemBuilder = inputs.darwin.lib.darwinSystem;
      platformModules = config.flake.modules.darwin;
    };

    nixosConfigurations = mkConfigurations {
      configurations = config.configurations.nixos;
      systemBuilder = inputs.nixpkgs.lib.nixosSystem;
      platformModules = config.flake.modules.nixos;
    };

    checks = lib.mkMerge [
      (mkChecks "darwin" config.flake.darwinConfigurations)
      (mkChecks "nixos" config.flake.nixosConfigurations)
    ];
  };
}
