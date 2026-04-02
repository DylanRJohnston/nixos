{ kit, ... }:
{
  kit.base.includes = [ kit.base._.homeDirectory ];

  kit.schema.user =
    { user, lib, ... }:
    {
      options.home = lib.mkOption {
        type = lib.types.str;
        default =
          {
            darwin = "/Users/${user.userName}";
            nixos = "/home/${user.userName}";
          }
          .${user.host.class};
      };
    };

  kit.base._.homeDirectory =
    { user, ... }:
    {
      os.users.users.${user.userName}.home = user.home;
    };
}
