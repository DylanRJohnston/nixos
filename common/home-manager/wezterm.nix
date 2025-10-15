{
  home.file.".config/wezterm/wezterm.lua".text = ''
    local wezterm = require 'wezterm';

    return {
      color_scheme = "Solarized Dark Higher Contrast",
      enable_tab_bar = false,
      font = wezterm.font('FiraCode Nerd Font Mono', { weight = 'Bold' }),
      font_size = 16,
      window_decorations = "RESIZE",
      native_macos_fullscreen_mode = true,
      keys = {
        { key = 'f', mods = 'CMD|CTRL', action = wezterm.action.ToggleFullScreen },
      },
    }
  '';
}
