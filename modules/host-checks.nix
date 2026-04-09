rec {
  imports = [ flake.flakeModule ];
  flake.flakeModule =
    { config, lib, ... }:
    let
      build =
        { name, value }:
        {
          inherit name;
          system = value.config.system.build.toplevel.system;
          value = value.config.system.build.toplevel;
        };

      flake.checks =
        [
          config.flake.nixosConfigurations
          config.flake.darwinConfigurations
        ]
        |> lib.map lib.attrsToList
        |> lib.flatten
        |> lib.map build
        |> lib.groupBy (host: host.system)
        |> lib.mapAttrs (_: lib.listToAttrs);
    in
    {
      inherit flake;
    };
}
