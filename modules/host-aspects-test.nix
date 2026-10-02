{ lib, unitTest, ... }:
let
  fixture =
    { arc, inputs, ... }:
    {
      arc.schema.host.config.flake = "/tmp/projection";

      arc.projection-baseline = {
        includes = [ ({ user, ... }: { user.home = user.home; }) ];
        nixos.imports = [ inputs.home-manager.nixosModules.home-manager ];
        darwin.imports = [ inputs.home-manager.darwinModules.home-manager ];
        homeManager.home.stateVersion = "26.05";
      };

      arc.projection-probe = {
        includes = [ arc.projection-probe._.left ];
        nixos.environment.variables.PROJECTION_PLATFORM = "nixos";
        darwin.environment.variables.PROJECTION_PLATFORM = "darwin";
        os.environment.variables.PROJECTION_OS = "shared";

        _.left.includes = [ arc.projection-probe._.right ];
        _.right.includes = [ arc.projection-probe._.leaf ];
        _.leaf = {
          os.environment.etc."projection-leaf".text = "once";

          homeManager.home.file."projection-leaf".text = "once";
          includes = [
            (
              { host, ... }:
              {
                os.environment.etc."projection-host".text = host.name;
              }
            )
            (
              { host, user, ... }:
              {
                user.description = "${host.name}/${user.userName}";
                homeManager.home.file."projection-context".text = "${host.name}/${user.userName}";
              }
            )
          ];
        };
      };
    };

  inspect = host: {
    platform = host.environment.variables.PROJECTION_PLATFORM;
    os = host.environment.variables.PROJECTION_OS;
    leaf = host.environment.etc."projection-leaf".text;
    context = host.environment.etc."projection-host".text;
    users = lib.genAttrs [ "alice" "robert" ] (name: {
      inherit (host.users.users.${name}) description home;
      leaf = host.home-manager.users.${name}.home.file."projection-leaf".text;
      context = host.home-manager.users.${name}.home.file."projection-context".text;
    });
  };

  platforms = {
    nixos = {
      system = "x86_64-linux";
      output = "nixosConfigurations";
      homeRoot = "/home";
    };
    darwin = {
      system = "aarch64-darwin";
      output = "darwinConfigurations";
      homeRoot = "/Users";
    };
  };

  platformTests =
    class:
    {
      system,
      output,
      homeRoot,
    }:
    let
      mkTest =
        enabled: check:
        unitTest (
          { arc, config, ... }:
          {
            imports = [ fixture ];
            den.hosts.${system}.projection = {
              users = {
                alice = { };
                bob.userName = "robert";
              };
              aspect.includes = [ arc.projection-baseline ] ++ lib.optional enabled arc.projection-probe;
            };
          }
          // check config.flake.${output}.projection.config
        );
    in
    {
      test-home-manager-module = unitTest (
        { arc, config, ... }:
        {
          imports = [ fixture ];
          den.hosts.${system}.projection = {
            users.alice = { };
            aspect.includes = [
              arc.projection-baseline
              { homeManager.home.file."projection-minimal".text = "projected"; }
            ];
          };
          expr = {
            classes = config.den.hosts.${system}.projection.users.alice.classes;
            stateVersion = config.flake.${output}.projection.config.home-manager.users.alice.home.stateVersion;
            text =
              config.flake.${output}.projection.config.home-manager.users.alice.home.file."projection-minimal".text;
          };
          expected = {
            classes = [
              "user"
              "homeManager"
            ];
            stateVersion = "26.05";
            text = "projected";
          };
        }
      );

      test-default-shell-with-user-shell = unitTest (
        {
          arc,
          config,
          den,
          ...
        }:
        {
          imports = [ fixture ];
          den.hosts.${system}.projection = {
            users.alice.aspect.includes = [ (den.batteries.user-shell "bash") ];
            aspect.includes = [ arc.base._.zsh._.default-shell ];
          };
          expr = config.flake.${output}.projection.config.users.users.alice.shell.pname;
          expected = "bash-interactive";
        }
      );

      test-platform-home-manager-bridge = unitTest (
        { arc, config, ... }:
        {
          imports = [ fixture ];
          den.hosts.${system}.projection = {
            users.alice = { };
            aspect.includes = [
              arc.base._.homeManager
              arc.base._.homeDirectory
              {
                os.homeManager.home.file."projection-shared".text = "shared";
                ${class}.homeManager = { config, ... }: {
                  home.file."projection-platform".text = "${class}/${config.home.username}";
                };
                homeManager.home.file."projection-direct".text = "direct";
              }
            ];
          };
          expr = {
            stateVersion = config.flake.${output}.projection.config.home-manager.users.alice.home.stateVersion;
            files = lib.genAttrs [ "projection-shared" "projection-platform" "projection-direct" ] (
              name: config.flake.${output}.projection.config.home-manager.users.alice.home.file.${name}.text
            );
          };
          expected = {
            stateVersion = "26.05";
            files = {
              projection-shared = "shared";
              projection-platform = "${class}/alice";
              projection-direct = "direct";
            };
          };
        }
      );

      test-transitive-projection = mkTest true (host: {
        expr = inspect host;
        expected = {
          platform = class;
          os = "shared";
          leaf = "once";
          context = "projection";
          users = lib.genAttrs [ "alice" "robert" ] (name: {
            description = "projection/${name}";
            home = "${homeRoot}/${name}";
            leaf = "once";
            context = "projection/${name}";
          });
        };
      });

      test-omitted-host-class = mkTest false (host: {
        expr = host.environment.variables.PROJECTION_PLATFORM;
        expectedError.msg = "attribute 'PROJECTION_PLATFORM' missing";
      });
      test-omitted-os-class = mkTest false (host: {
        expr = host.environment.etc."projection-leaf".text;
        expectedError.msg = "attribute 'projection-leaf' missing";
      });
      test-omitted-user-class = mkTest false (host: {
        expr = host.users.users.alice.description;
        expected = if class == "darwin" then null else "";
      });
      test-omitted-home-manager-class = mkTest false (host: {
        expr = host.home-manager.users.alice.home.file."projection-leaf".text;
        expectedError.msg = "attribute '(alice|projection-leaf)' missing";
      });

      test-host-without-users = unitTest (
        { arc, config, ... }:
        {
          imports = [ fixture ];
          den.hosts.${system}.projection.aspect.includes = [ arc.projection-probe ];
          expr = {
            leaf = config.flake.${output}.projection.config.environment.etc."projection-leaf".text;
            context = config.flake.${output}.projection.config.environment.etc."projection-host".text;
          };
          expected = {
            leaf = "once";
            context = "projection";
          };
        }
      );
    };
in
{
  flake.tests.host-aspects = lib.mapAttrs platformTests platforms // {
    test-same-user-on-distinct-hosts = unitTest (
      { arc, config, ... }:
      {
        imports = [ fixture ];
        den.hosts.x86_64-linux = lib.genAttrs [ "first" "second" ] (_: {
          users.alice = { };
          aspect.includes = [
            arc.projection-baseline
            arc.projection-probe
          ];
        });
        expr =
          map
            (
              name:
              config.flake.nixosConfigurations.${name}.config.home-manager.users.alice.home.file."projection-context".text
            )
            [
              "first"
              "second"
            ];
        expected = [
          "first/alice"
          "second/alice"
        ];
      }
    );
  };
}
