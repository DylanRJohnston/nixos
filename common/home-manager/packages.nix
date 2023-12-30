{ pkgs, ... }: {
  home.packages = with pkgs; [
    # awscli2
    (google-cloud-sdk.withExtraComponents
      [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
    cachix
    fd
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
    nixfmt
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
