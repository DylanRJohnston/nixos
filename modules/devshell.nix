{
  inputs,
  config,
  den,
  lib,
  ...
}:
{
  flake = den.lib.perSystem (
    { pkgs, system }:
    let
      flakePackages = lib.attrValues config.flake.packages.${system};
      # beads = inputs.beads.packages.${system}.default;
    in
    {
    }
  );
}
