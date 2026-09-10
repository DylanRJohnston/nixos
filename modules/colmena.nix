let
  module =
    {
      arc,
      den,
      inputs,
      lib,
      nixosAspectTest,
      unitTest,
      ...
    }:
    let
      nixosHosts =
        den.hosts
        |> lib.attrValues
        |> lib.concatMap lib.attrValues
        |> lib.filter (host: host.class == "nixos")
        |> lib.map (host: lib.nameValuePair host.name host)
        |> lib.listToAttrs;

      rawHive = {
        meta = {
          nixpkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
          nodeNixpkgs = lib.mapAttrs (_: host: inputs.nixpkgs.legacyPackages.${host.system}) nixosHosts;
        };
      }
      // lib.mapAttrs (
        _: host: den.lib.aspects.resolve "nixos" (den.ctx.host { inherit host; })
      ) nixosHosts;
    in
    {
      options.flake = {
        colmena = lib.mkOption {
          type = lib.types.raw;
          readOnly = true;
          description = "The raw Colmena hive generated from den's NixOS hosts.";
        };

        colmenaHive = lib.mkOption {
          type = lib.types.raw;
          readOnly = true;
          description = "The directly evaluable Colmena hive.";
        };
      };

      config.arc.development.os =
        { pkgs, ... }:
        {
          environment.systemPackages = [ inputs.colmena.packages.${pkgs.stdenv.hostPlatform.system}.colmena ];
        };

      config.flake = {
        colmena = rawHive;
        colmenaHive = inputs.colmena.lib.makeHive rawHive;

        packages = inputs.colmena.packages;

        tests.colmena = {
          test-hive = unitTest (
            { config, ... }:
            {
              den.hosts.x86_64-linux.igloo = {
                users.tux = { };
                aspects = [ arc.base ];
              };
              den.hosts.aarch64-darwin.apple = {
                users.tux = { };
                aspects = [ arc.base ];
              };

              expr = {
                includesNixosHost = config.flake.colmenaHive.nodes ? igloo;
                excludesDarwinHost = !(config.flake.colmenaHive.nodes ? apple);
                hostName = config.flake.colmenaHive.nodes.igloo.config.networking.hostName;
                targetHost = config.flake.colmenaHive.deploymentConfig.igloo.targetHost;
              };
              expected = {
                includesNixosHost = true;
                excludesDarwinHost = true;
                hostName = "igloo";
                targetHost = "igloo";
              };
            }
          );

          package = nixosAspectTest {
            baseline = [ arc.base ];
            aspects = [ arc.development ];
            expr = igloo: lib.any (package: lib.getName package == "colmena") igloo.environment.systemPackages;
            enabled = true;
            disabled = false;
          };
        };
      };
    };
in
{
  imports = [ module ];
  flake.flakeModule = module;
}
