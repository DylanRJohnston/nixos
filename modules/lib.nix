{ den, ... }:
{
  den.lib.nixos =
    aspect: den.lib.perHost ({ host, ... }: if host.class == "nixos" then aspect else { });

  den.lib.darwin =
    aspect: den.lib.perHost ({ host, ... }: if host.class == "darwin" then aspect else { });
}
