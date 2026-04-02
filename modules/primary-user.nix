{
  arc,
  lib,
  ...
}:
{
  arc.base.includes = [ arc.base._.primaryUser ];

  arc.base._.primaryUser = {
    os.system.primaryUser = "dylanj";

    nixos.options.system.primaryUser = lib.mkOption {
      type = lib.types.str;
      default = "dylanj";
      description = "The primary user of the system";
    };
  };
}
