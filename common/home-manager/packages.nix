{ pkgs, ... }: {
  home.packages = with pkgs; [
    awscli2
    cachix
    fd
    fzf
    git
    git-town
    gnupg
    (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
    htop
    iftop
    jq
    killall
    lsof
    mosh
    ngrok
    nixpkgs-fmt
    pv
    rnix-lsp
    sops
    tmux
    tree
    wget
    zstd
  ];
}
