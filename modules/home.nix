{ arc, ... }:
{
  arc.base.includes = [ arc.base._.homeDirectory ];

  arc.schema.user =
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

  arc.base._.homeDirectory =
    { user, ... }:
    {
      user.home = user.home;
    };
}
