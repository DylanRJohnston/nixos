{
  flake.modules.homeManager.base =
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
        nixd
        nixfmt
        nixpkgs-fmt
        pv
        sops
        tmux
        tree
        wget
        zstd
      ];
    };
}
