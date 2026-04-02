{
  kit = {
    base = {
      os =
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
            alejandra
            pv
            tmux
            tree
            vim
            wget
          ];
        };

      nixos =
        { pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [
            _1password-gui
            pulseaudio
          ];
        };

      homeManager =
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
    };

    development.homeManager =
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
  };
}
