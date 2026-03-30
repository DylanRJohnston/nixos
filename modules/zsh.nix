{
  den.aspects.base = {
    os =
      { config, pkgs, ... }:
      {
        users.users.${config.system.primaryUser}.shell = pkgs.zsh;
        programs.zsh.enable = true;
      };

    nixos.homeManager.programs.zsh.shellAliases = {
      "battery" = "cat /sys/class/power_supply/BAT0/capacity";
      "pbcopy" = "xclip -i -selection clipboard";
      "pbpaste" = "xclip -o -selection clipboard";
      "headphones" =
        "bluetoothctl connect 70:26:05:E0:AC:84 && sleep 2 && bluetoothctl connect 70:26:05:E0:AC:84";
      "mouse" = "bluetoothctl connect EB:33:0A:19:B9:15 && sleep 2 blueoothctl connect EB:33:0A:19:B9:15";
      "zed" = "zeditor";
    };

    darwin.homeManager.programs.zsh.sessionVariables = {
      PATH = "$PATH:/opt/homebrew/bin";
      APPLE_SSH_ADD_BEHAVIOR = "macos";
    };

    homeManager =
      { pkgs, ... }:
      {
        programs.starship = {
          enable = true;
          enableZshIntegration = true;
        };

        programs.zsh = {
          enable = true;
          autosuggestion.enable = true;
          syntaxHighlighting.enable = true;
          shellAliases = {
            gitlog = "git log --oneline --graph --all";
            v = "vim $(fd --type f | fzf)";
          };
          oh-my-zsh = {
            enable = true;
            plugins = [
              "docker"
              "docker-compose"
              "fzf"
            ];
          };
          plugins = [
            {
              name = "enhancd";
              file = "init.sh";
              src = pkgs.fetchFromGitHub {
                owner = "b4b4r07";
                repo = "enhancd";
                rev = "230695f8da8463b18121f58d748851a67be19a00";
                hash = "sha256-XJl0XVtfi/NTysRMWant84uh8+zShTRwd7t2cxUk+qU=";
              };
            }
          ];
          sessionVariables = {
            EDITOR = "zed --wait";
            LC_ALL = "en_US.UTF-8";
            LANG = "en_US.UTF-8";
            DEFAULT_USER = "dylanj";
            ENHANCD_DOT_ARG = "back";
            GOPATH = "$HOME/Workspace/go";
          };
          initContent = ''
            if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
              tmux attach -t default || tmux new -s default
            fi
          '';
        };
      };
  };
}
