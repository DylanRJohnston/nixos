{ pkgs, ... }: {
  programs.vim = {
    enable = true;

    settings = {
      number = true;
      expandtab = true;
      background = "dark";
    };

    extraConfig = ''
      colorscheme solarized
    '';

    plugins = with pkgs.vimPlugins; [
      vim-nix
      vim-colors-solarized
    ];
  };
}
