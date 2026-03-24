{ lib, den, ... }:
{
  kit.schema.host.options.roles = lib.mkOption {
    type = lib.types.listOf den.lib.aspects.types.aspectSubmodule;
  };
}
