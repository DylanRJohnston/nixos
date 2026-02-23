{
  lib,
  config,
  pkgs,
  ...
}:
    let
      homePrefix = if pkgs.stdenv.isDarwin then "/Users" else "/home";
    in
{
  options = {
    custom.primaryUser = lib.mkOption {
      type = lib.types.str;
      default = "dylanj";
      description = "The primary user for the system";
    };
  };

  config =
    {
      users.users.${config.custom.primaryUser}.home = "${homePrefix}/${config.custom.primaryUser}";
    };
}
