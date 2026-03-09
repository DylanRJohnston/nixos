{
  flake.modules.darwin.gaming.homebrew.casks = [ "steam" ];
  flake.modules.nixos.gaming =
    {
      pkgs,
      ...
    }:
    {
      programs.steam.enable = true;
      programs.steam.gamescopeSession.enable = true;
      programs.gamemode.enable = true;

      environment.systemPackages = with pkgs; [
        mangohud
        gamescope-wsi
      ];
    };
}
