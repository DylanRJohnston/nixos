{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # awscli2
    (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
    cachix
    claude-code
    commitizen
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
    nil
    nixd
    nixfmt-rfc-style
    nixpkgs-fmt
    pv
    sops
    tmux
    tree
    wget
    zstd
  ];
}
