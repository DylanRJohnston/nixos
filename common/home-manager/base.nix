{ common, ... }: {
  imports = with common; [
    direnv
    git
    home-manager
    gpg-agent
    packages
    ssh
    tmux
    vim
    vscode
    wezterm
    zsh
  ];
}
