{ lib, ... }:
{
  options.custom.roles = lib.mkOption {
    type = lib.types.listOf (
      lib.types.enum [
        "base"
        "development"
        "gaming"
        "entertainment"
        "work"
      ]
    );
    default = [ ];
    description = "List of roles to enable";
  };

  # We use this instead of default so by default
  # additional roles are appended instead of replacing
  # the lower priority "default" value while still allowing
  # someone to override the base role if required with
  # lib.mkForce
  config.custom.roles = [ "base" ];
}
