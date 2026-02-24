{
  inputs,
  config,
  lib,
  ...
}:
let
  inherit (inputs.darwin.lib) darwinSystem;
  inherit (inputs.nixpkgs.lib) nixosSystem;
  inherit (config.flake) mergeTargets;

  mkSystem = platform: if platform == "darwin" then darwinSystem else nixosSystem;

  mkConfigurations =
    platform: configurations:
    configurations
    |> lib.filterAttrs (_: target: target.platform == platform)
    |> lib.mapAttrs (
      name: target:
      mkSystem platform {
        modules = [
          target.module
        ];
      }
    );
in
{
  flake = {
    darwinConfigurations = mkConfigurations "darwin" mergeTargets;
    nixosConfigurations = mkConfigurations "nixos" mergeTargets;
  };
}
