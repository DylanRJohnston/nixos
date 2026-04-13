{ den, lib, ... }:
{
  den.lib.strict = {
    _module.freeformType = lib.mkForce null;
  };

  arc.schema.user = den.lib.strict;
  arc.schema.host = den.lib.strict;
  arc.schema.aspect = den.lib.strict;
}
