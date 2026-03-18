{ lib, ... }:
let
  inherit (lib) mkOption types;
  inherit (lib.generators) mkLuaInline toLua;
in
{
  kit.base = {
    homeManager =
      { config, ... }:
      {
        options.custom.wezterm.config = mkOption {
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
            window_decorations = "RESIZE";
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
      };

    darwin.homeManager.custom.wezterm.config = {
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
