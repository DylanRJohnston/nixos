{
  kit.gaming.nixos =
    { config, ... }:
    {
      security.polkit.enable = true;
      users.users.${config.system.primaryUser}.extraGroups = [ "gamemode" ];
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
}
