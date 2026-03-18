{
  kit.gaming = {
    darwin.homebrew.casks = [ "steam" ];
    nixos =
      { pkgs, ... }:
      {
        programs.steam.enable = true;
        programs.steam.gamescopeSession.enable = true;
        programs.gamemode.enable = true;

        environment.systemPackages = with pkgs; [
          mangohud
          gamescope-wsi
        ];
      };
  };
}
