{ pkgs, ... }:
{
  home.packages = with pkgs; [
    htop
    fortune
    google-chrome
    _1password
    tmux
    vscode
    feh
    git
    alacritty
    i3lock-color
    git-town
    nixpkgs-fmt
    flameshot
    spotify
    playerctl
    rustc
    cargo
    gcc
    fzf
  ];
}
