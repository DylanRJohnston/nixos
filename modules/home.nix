let
  home =
    prefix:
    { config, ... }:
    let
      user = config.system.primaryUser;
    in
    {
      users.users.${user}.home = "${prefix}/${user}";
    };
in
{
  kit.base = {
    darwin = home "/Users";
    nixos = home "/home";
  };
}
