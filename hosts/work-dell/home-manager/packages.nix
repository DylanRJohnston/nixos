{ pkgs, ... }:
let
  applications = with pkgs; [
    _1password-gui
    alacritty
    feh
    flameshot
    google-chrome
    postman
    spotify
    vscode
  ];
  clis = with pkgs; [
    # awscli2
    brightnessctl
    docker-compose
    fzf
    gcc
    git
    git-crypt
    git-town
    htop
    i3lock-color
    iftop
    jq
    killall
    lsof
    ngrok
    nixpkgs-fmt
    playerctl
    tmux
    xclip
  ];
in
{
  home.packages = applications ++ clis;
}
