{ ... }:
let
  system =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        fd
        fzf
        git
        git-town
        htop
        iftop
        jq
        killall
        lsof
        nixd
        nixfmt
        nixpkgs-fmt
        pv
        tmux
        tree
        vim
        wget
      ];
    };

  home_base =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        commitizen
        gnupg
        mosh
        sops
        zstd
      ];

    };

  home_development =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        awscli2
        binaryen
        cachix
        claude-code
        kubectl
        kubectx
        nmap
      ];
    };
in
{
  den.aspects = {
    base.os = system;
    base.homeManager = home_base;
    development.homeManager = home_development;
  };
}
