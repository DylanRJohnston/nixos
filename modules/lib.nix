{ den, ... }:
let
  conditionalAspect =
    class: aspect: den.lib.take.upTo ({ host }: if host.class == class then aspect else { });
in
{
  den.lib.nixos = conditionalAspect "nixos";
  den.lib.darwin = conditionalAspect "darwin";
}
