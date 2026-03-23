{ lib, kit, ... }:
let
  inherit (lib) mkOption types debug;
  inherit (lib.generators) mkLuaInline toLua;
in
{
  # kit.base.includes = [ kit.base.provides.wezterm ];

  kit.base = {
    homeManager = lib.debug.traceSeq "1237182372837 setting wezterm homeManager" (
      { config, ... }:
      {
        options.custom.wezterm.config = lib.debug.traceSeq "setting wezterm config option" lib.mkOption {
          type = types.submodule {
            freeformType = types.anything;
          };

          description = "Custom wezterm configuration, the 'wezterm' import is in scope";
          example = ''
            custom.wezterm.config = {
              color_scheme = "Solarized Dark Higher Contrast";
              font = mkLuaInline "wezterm.font('FiraCode Nerd Font Mono')";
            };
          '';
        };

        config = {
          custom.wezterm.config = {
            color_scheme = "Solarized Dark Higher Contrast";
            enable_tab_bar = false;
            font = mkLuaInline "wezterm.font('FiraCode Nerd Font Mono')";
            font_size = 16;
            window_decorations = lib.mkDefault "NONE";
            window_padding = {
              left = 0;
              right = 0;
              top = 0;
              bottom = 0;
            };
          };

          home.file.".config/wezterm/wezterm.lua".text = ''
            local wezterm = require 'wezterm';

            return ${toLua { } config.custom.wezterm.config}
          '';
        };
      }
    );

    darwin.homeManager.custom.wezterm.config = {
      window_decorations = "RESIZE";
      native_macos_fullscreen_mode = true;
      keys = [
        {
          key = "f";
          mods = "CMD|CTRL";
          action = mkLuaInline "wezterm.action.ToggleFullScreen";
        }
      ];
    };
  };
}
