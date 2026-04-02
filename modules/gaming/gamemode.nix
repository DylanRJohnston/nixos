{ arc, ... }:
{
  arc.gaming = {
    includes = [
      arc.gaming._.gamemode
      arc.gaming._.gamemode._.permissions
    ];

    _.gamemode.nixos = {
      security.polkit.enable = true;
      programs.gamemode = {
        enable = true;
        enableRenice = true;
        settings = {
          general = {
            softrealtime = "auto";
            renice = 10;
            desiredgov = "performance";
            defaultgov = "schedutil";
          };
        };
      };
    };

    _.gamemode._.permissions =
      { user, ... }:
      {
        nixos.users.users.${user.userName}.extraGroups = [ "gamemode" ];
      };
  };
}
