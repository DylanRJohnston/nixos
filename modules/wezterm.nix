{ lib, arc, ... }:
let
  inherit (lib.generators) mkLuaInline toLua;
in
{
  arc.base.includes = [ arc.base._.wezterm ];

  arc.base._.wezterm = {
    homeManager = (
      { config, ... }:
      {
        options.programs.wezterm.config = lib.mkOption {
          type = lib.types.submodule {
            freeformType = lib.types.anything;
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
          programs.wezterm.config = {
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

            return ${toLua { } config.programs.wezterm.config}
          '';
        };
      }
    );

    darwin = {
      homeManager.programs.wezterm.config = {
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
  };
}
