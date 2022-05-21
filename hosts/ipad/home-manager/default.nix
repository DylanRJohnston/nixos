{ pkgs, common, ... }: {
  imports = with common; [
    alacritty
    direnv
    git
    vim
    vscode
    zsh
    tmux
    home-manager
    gpg-agent
    packages
  ];
 }


