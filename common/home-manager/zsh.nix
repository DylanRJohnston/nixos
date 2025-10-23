{ pkgs, lib, ... }:
let
  aliases = {
    shared = {
      gitlog = "git log --oneline --graph --all";
      v = "vim $(fd --type f | fzf)";
      fz-tunnel-cockroach-us-central = ''$(sops -d --extract '["ums"]["production"]["us-central"]' ${../../secrets/tunnels.yaml})'';
      fz-tunnel-cockroach-staging = ''$(sops -d --extract '["ums"]["staging"]' ${../../secrets/tunnels.yaml})'';
    };
    linux = {
      "battery" = "cat /sys/class/power_supply/BAT0/capacity";
      "pbcopy" = "xclip -i -selection clipboard";
      "pbpaste" = "xclip -o -selection clipboard";
      "headphones" =
        "bluetoothctl connect 70:26:05:E0:AC:84 && sleep 2 && bluetoothctl connect 70:26:05:E0:AC:84";
    };
    darwin = { };
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
in
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "docker"
        "docker-compose"
        "fzf"
      ];
    };
    plugins = plugins;
    localVariables = {
      EDITOR = "code --wait";
      LC_ALL = "en_US.UTF-8";
      LANG = "en_US.UTF-8";
      DEFAULT_USER = "dylanj";
      POWERLEVEL9K_SHORTEN_DIR_LENGTH = 1;
      POWERLEVEL9K_SHORTEN_DELIMITER = "";
      POWERLEVEL9K_SHORTEN_STRATEGY = "truncate_from_right";
      POWERLEVEL9K_LEFT_PROMPT_ELEMENTS = [
        "dir"
        "vcs"
      ];
      POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS = [
        "status"
        "root_indicator"
        "background_jobs"
        "history"
      ];
      ENHANCD_DOT_ARG = "back";
      GOPATH = "$HOME/Workspace/go";
      PATH = "$PATH:/opt/homebrew/bin";
      APPLE_SSH_ADD_BEHAVIOR = "macos";
    };
    shellAliases = lib.mkMerge [
      aliases.shared
      (lib.optionalAttrs pkgs.stdenv.isLinux aliases.linux)
      (lib.optionalAttrs pkgs.stdenv.isDarwin aliases.darwin)
    ];
    initContent = ''
      source ${pkgs.zsh-powerlevel9k}/share/zsh-powerlevel9k/powerlevel9k.zsh-theme
      if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
        tmux attach -t default || tmux new -s default
      fi
    '';
  };
}
