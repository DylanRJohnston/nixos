{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.custom.vim.enable = lib.mkEnableOption "Enable vim configuration";

  config.programs.vim = lib.mkIf config.custom.vim.enable {
    enable = true;

    settings = {
      number = true;
      expandtab = true;
      background = "dark";
    };

    extraConfig = ''
      let g:solarized_termcolors=256
      set t_Co=256
      colorscheme solarized
    '';

    plugins = with pkgs.vimPlugins; [
      vim-nix
      vim-colors-solarized
    ];
  };
}
