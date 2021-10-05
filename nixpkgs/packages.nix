{ pkgs, ... }:
let
  applications = with pkgs; [
    _1password-gui
    alacritty
    feh
    flameshot
    google-chrome
    spotify
    vscode
  ];
  clis = with pkgs; [
    awscli2
    brightnessctl
    fzf
    gcc
    git
    git-crypt
    git-town
    htop
    i3lock-color
    iftop
    lsof
    nixpkgs-fmt
    playerctl
    tmux
    xclip
  ];
in
{
  home.packages = applications ++ clis;
}
