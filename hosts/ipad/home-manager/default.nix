{ pkgs, common, ... }: {
  imports = with common; [
    alacritty
    direnv
    git
    vim
    vscode
    zsh
    tmux
  ];

  home.packages = with pkgs; [
    cachix
    fzf
    git-town
    htop
    iftop
    jq
    killall
    lsof
    ngrok
    nixpkgs-fmt
    tmux
  ];

  programs.home-manager = {
    enable = true;
  };
}


