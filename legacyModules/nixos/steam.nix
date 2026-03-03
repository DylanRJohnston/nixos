{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.custom.steam;
in
{
  options.custom.steam.enable = lib.mkEnableOption "Enable steam";

  config = lib.mkIf cfg.enable {
    programs.steam.enable = true;
    programs.steam.gamescopeSession.enable = true;
    programs.gamemode.enable = true;

    environment.systemPackages = with pkgs; [
      mangohud
      gamescope-wsi
    ];
  };
}
