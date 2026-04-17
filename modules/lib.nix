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
  den.lib.perSystem =
    fn:
    [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ]
    |> lib.map (
      system:
      fn {
        inherit system;
        pkgs = inputs.nixpkgs.legacyPackages.${system};
      }
      |> lib.attrsToList
      |> lib.map (
        { name, value }:
        {
          kind = name;
          name = system;
          value = value;
        }
      )
    )
    |> lib.flatten
    |> lib.groupBy (it: it.kind)
    |> lib.mapAttrs (_: lib.listToAttrs);

}
