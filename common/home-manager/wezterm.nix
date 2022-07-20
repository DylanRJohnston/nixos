{ pkgs, ... }: {
  home.file.".config/wezterm/wezterm.lua".text = ''
    local wezterm = require 'wezterm';

    return {
      color_scheme = "Solarized Dark Higher Contrast",
      enable_tab_bar = false,
      font = wezterm.font('FiraCode Nerd Font Mono', { weight = 'Bold' }),
      font_antialias = "Subpixel",
      font_size = 16,
      window_decorations = "RESIZE",
    }
  '';
}
