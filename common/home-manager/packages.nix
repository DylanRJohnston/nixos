{ pkgs, ... }: {
  home.packages = with pkgs; [
    awscli2
    cachix
    fd
    fzf
    git
    git-town
    gnupg
    google-cloud-sdk
    htop
    iftop
    jq
    killall
    lsof
    mosh
    # ngrok
    nixpkgs-fmt
    pv
    rnix-lsp
    tmux
    zstd
  ];
}
