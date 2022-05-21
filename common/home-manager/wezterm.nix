{ pkgs, ... }: {
  home.packages = [ pkgs.wezterm ];

  home.file.".config/wezterm/wezterm.lua".text = ''
    local wezterm = require 'wezterm';

    return {
      color_scheme = "Solarized Dark Higher Contrast",
      font = wezterm.font("FiraCode Nerd Font Mono");
    }
  '';
}
