{ common, ... }: {
  imports = with common; [
    alacritty
    direnv
    git
    home-manager
    packages
    ssh
    tmux
    vim
    vscode
    wezterm
    zsh
  ];
}
