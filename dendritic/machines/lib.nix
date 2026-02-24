{ lib, config, ... }:
{
  flake.lib.perMachine = fn: config.flake.machines |> lib.mapAttrs (_: fn);
}
