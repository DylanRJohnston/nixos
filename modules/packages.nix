{
  flake.modules =
    let
      system =
        pkgs: with pkgs; [
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

      home_base =
        pkgs: with pkgs; [
          commitizen
          gnupg
          mosh
          sops
          zstd
        ];

      home_development =
        pkgs: with pkgs; [
          awscli2
          binaryen
          cachix
          claude-code
          kubectl
          kubectx
          nmap
        ];
    in
    {
      generic.base =
        { pkgs, ... }:
        {
          environment.systemPackages = system pkgs;
        };

      homeManager.base =
        { pkgs, ... }:
        {
          home.packages = home_base pkgs;
        };

      homeManager.development =
        { pkgs, ... }:
        {
          home.packages = home_development pkgs;
        };
    };
}
