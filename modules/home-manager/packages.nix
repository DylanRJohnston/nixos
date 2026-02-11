{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.custom.packages.enable = lib.mkEnableOption "Enable packages module";

  config.home.packages =
    with pkgs;
    lib.mkIf config.custom.packages.enable [
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
      # ngrok
      nil
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
}
