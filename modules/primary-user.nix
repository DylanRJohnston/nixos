{ lib, ... }:
{
  den.aspects.base = {
    os.system.primaryUser = "dylanj";

    nixos.options.system.primaryUser = lib.mkOption {
      type = lib.types.str;
      default = "dylanj";
      description = "The primary user of the system";
    };
  };
}
