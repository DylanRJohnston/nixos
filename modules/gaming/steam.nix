{
  arc.gaming = {
    darwin.homebrew.casks = [ "steam" ];
    nixos =
      {
        pkgs,
        lib,
        config,
        ...
      }:
      {
        options.programs.steam.extraEnv = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
        };

        config = {
          programs.steam = {
            enable = true;
            gamescopeSession.enable = true;
            extraEnv.VKD3D_CONFIG = "dxr,dxr11";
            package = pkgs.steam.override {
              inherit (config.programs.steam) extraEnv;
            };
          };

          environment.systemPackages = with pkgs; [
            mangohud
            gamescope-wsi
          ];
        };
      };

  };
}
