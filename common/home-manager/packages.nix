{ pkgs, ... }: {
  home.packages = with pkgs; [
    cachix
    fzf
    git
    git-town
    gnupg
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
