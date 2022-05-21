{ pkgs, common, ... }: {
  imports = with common; [
    alacritty
    direnv
    git
    i3
    compton
    vim
    vscode
    zsh
    tmux
    home-manager
    gpg-agent
    packages
    wezterm
  ];

  programs.firefox.enable = true;
  programs.rofi.enable = true;
}

