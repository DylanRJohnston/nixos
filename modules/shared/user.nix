{ lib, config, ... }:
{
  options = {
    custom.primaryUser = lib.mkOption {
      type = lib.types.str;
      description = "The primary user for the system";
    };
    custom.homePrefix = lib.mkOption {
      type = lib.types.str;
      description = "The path prefix for the user's home directory";
      example = "/home";
    };
  };

  config = {
    users.users.${config.custom.primaryUser}.home =
      "${config.custom.homePrefix}/${config.custom.primaryUser}";
  };
}
