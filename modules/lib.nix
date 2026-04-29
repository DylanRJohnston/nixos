{
  inputs,
  den,
  lib,
  ...
}:
let
  conditionalAspect =
    class: aspect: den.lib.take.upTo ({ host }: if host.class == class then aspect else { });
in
{
  den.lib.nixos = conditionalAspect "nixos";
  den.lib.darwin = conditionalAspect "darwin";
  den.lib.perSystem = den.lib.withSystems [
    "x86_64-linux"
    "aarch64-linux"
    "aarch64-darwin"
  ];
  den.lib.withSystems =
    systems: fn:
    lib.genAttrs systems (
      system:
      fn {
        inherit system;
        pkgs = inputs.nixpkgs.legacyPackages.${system};
      }
    );

}
