{
  lib,
  config,
  ...
}:
let
  mkChecks =
    system: configurations:
    configurations
    |> lib.mapAttrsToList (
      name: machine:
      let
        platform = machine.config.nixpkgs.hostPlatform.system;
      in
      {
        "configurations-${platform}-${name}" = derivation {
          name = "check-${platform}-${name}";
          builder = "/bin/bash";
          system = system;
          args = [
            "-c"
            "echo ${machine.config.system.build.toplevel.drvPath} > $out"
          ];
        };
      }
    )
    |> lib.mkMerge;
in
{
  perSystem =
    { system, ... }:
    {
      checks = lib.mkMerge [
        (mkChecks system config.flake.darwinConfigurations)
        (mkChecks system config.flake.nixosConfigurations)
      ];
    };
}
