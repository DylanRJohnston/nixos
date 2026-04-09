rec {
  imports = [ flake.flakeModule.host-checks ];
  flake.flakeModule.host-checks =
    { config, lib, ... }:
    let
      build =
        { name, value }:
        {
          system = value.config.system.build.toplevel.system;

          name = name;
          value = value.config.system.build.toplevel;
        };

      checks =
        [
          config.flake.nixosConfigurations or { }
          config.flake.darwinConfigurations or { }
        ]
        |> lib.map lib.attrsToList
        |> lib.flatten
        |> lib.map build
        |> lib.groupBy (host: host.system)
        |> lib.mapAttrs (_: lib.listToAttrs);
    in
    {
      flake.checks = checks;
    };
}
