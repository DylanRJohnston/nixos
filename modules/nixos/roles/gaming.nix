{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf (builtins.elem "gaming" config.custom.roles) {
    environment.systemPackages = with pkgs; [ mangohud ];

    programs.steam.enable = true;
    programs.steam.gamescopeSession.enable = true;
    programs.gamemode.enable = true;
  };
}
