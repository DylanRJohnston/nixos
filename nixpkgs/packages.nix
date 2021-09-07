{ pkgs, ... }:
{
  home.packages = with pkgs; [
    htop
    fortune
    google-chrome
    _1password
    vim
    tmux
    vscode
    feh
    git
    alacritty
    i3lock-color
    git-town
    nixpkgs-fmt
    flameshot
  ];
}
