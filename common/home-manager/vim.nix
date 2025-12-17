{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.custom.modules.vim.enable = lib.mkEnableOption "Enable vim configuration";

  config.programs.vim = lib.mkIf config.custom.modules.vim.enable {
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
