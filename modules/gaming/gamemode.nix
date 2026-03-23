{
  kit.gaming.nixos =
    { pkgs, ... }:
    {
      programs.gamemode = {
        enable = true;
        enableRenice = true;
        settings = {
          general = {
            softrealtime = "auto";
            renice = 10;
          };
          custom = {
            start = "${pkgs.libnotify}/bin/notify-send 'GameMode' 'Optimisation Active'";
            end = "${pkgs.libnotify}/bin/notify-send 'GameMode' 'Optimisation Deactivated'";
          };
        };
      };

      programs.steam.extraEnv = {
        GAMEMODERUN = "1";
      };
    };
}
