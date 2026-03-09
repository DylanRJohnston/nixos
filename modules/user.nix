{
  flake.modules.generic.base.system.primaryUser = "dylanj";
  flake.modules.darwin.base =
    { config, ... }:
    {
      users.users.${config.system.primaryUser}.home = "/Users/${config.system.primaryUser}";
    };

  flake.modules.nixos.base =
    { config, lib, ... }:
    {
      options.system.primaryUser = lib.mkOption {
        type = lib.types.str;
        default = "dylanj";
        description = "The primary user of the system";
      };

      config.users.users.${config.system.primaryUser}.home = "/home/${config.system.primaryUser}";
    };
}
