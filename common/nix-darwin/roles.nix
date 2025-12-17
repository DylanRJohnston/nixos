{ lib, ... }:
{
  options.custom.roles = lib.mkOption {
    type = lib.types.listOf (
      lib.types.enum [
        "base"
        "development"
        "gaming"
        "work"
      ]
    );
    default = [ "base" ];
    description = "List of roles to enable";
  };
}
