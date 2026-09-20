{
  den,
  arc,
  unitTest,
  ...
}:
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
            defaultgov = "powersave";
          };
        };
      };
    };

    _.gamemode._.permissions = den.lib.nixos {
      user.extraGroups = [ "gamemode" ];
    };
  };

  flake.tests.gamemode.test-governors = unitTest (
    { arc, igloo, ... }:
    {
      den.hosts.x86_64-linux.igloo = {
        users.tux = { };
        aspects = with arc; [
          base
          gaming
        ];
      };

      expr = {
        inherit (igloo.programs.gamemode.settings.general) desiredgov defaultgov;
      };
      expected = {
        desiredgov = "performance";
        defaultgov = "powersave";
      };
    }
  );
}
