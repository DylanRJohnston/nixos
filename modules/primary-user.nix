{
  kit,
  lib,
  ...
}:
{
  kit.base.includes = [ kit.base._.primaryUser ];

  kit.base._.primaryUser = {
    os.system.primaryUser = "dylanj";

    nixos.options.system.primaryUser = lib.mkOption {
      type = lib.types.str;
      default = "dylanj";
      description = "The primary user of the system";
    };
  };
}
