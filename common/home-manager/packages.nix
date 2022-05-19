{ pkgs, ... }: {
  home.packages = with pkgs; [
    cachix
    fzf
    git
    git-town
    htop
    iftop
    jq
    killall
    lsof
    ngrok
    nixpkgs-fmt
    pv
    tmux
    vim
    zstd
  ];
}
