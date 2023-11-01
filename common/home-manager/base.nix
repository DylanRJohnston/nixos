{ common, ... }: {
  imports = with common; [
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
