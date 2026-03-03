{
  flake.modules.generic.base =
    {
      pkgs,
      config,
      ...
    }:
    let
      homePrefix = if pkgs.stdenv.isDarwin then "/Users" else "/home";
    in
    {
      system.primaryUser = "dylanj";
      users.users.${config.system.primaryUser}.home = "${homePrefix}/${config.system.primaryUser}";
    };

  flake.modules.nixos.base =
    { lib, ... }:
    {
      options.system.primaryUser = lib.mkOption {
        type = lib.types.str;
        default = "dylanj";
        description = "The primary user of the system";
      };
    };
}
