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
    mosh
    ngrok
    nixpkgs-fmt
    pv
    tmux
    zstd
  ];
}
