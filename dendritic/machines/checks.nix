{ lib, config, ... }:
let
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
  flake.checks = lib.mkMerge [
    (mkChecks "darwin" config.flake.darwinConfigurations)
    (mkChecks "nixos" config.flake.nixosConfigurations)
  ];
}
