{ pkgs, common, ... }: {
  imports = with common; [
    alacritty
    direnv
    git
    home-manager
    packages
    tmux
    vim
    vscode
    zsh
  ];
}


