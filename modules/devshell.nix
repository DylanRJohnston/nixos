{
  # inputs,
  config,
  perSystem,
  lib,
  ...
}:
{
  flake = perSystem (
    { pkgs, system }:
    let
      flakePackages = lib.attrValues config.flake.packages.${system};
      # beads = inputs.beads.packages.${system}.default.override (prev: {
      #   goBuildModule = args: prev.goBuildModule args // { vendorHash = "fuck"; };
      # });
    in
    {
      # packages.beads = beads;

      devShells.default = pkgs.mkShell {
        buildInputs = flakePackages;
      };
    }
  );
}
