{ lib, config, ... }:
{
  flake.lib.perMachine = fn: config.machines |> lib.mapAttrs (_: fn);
}
