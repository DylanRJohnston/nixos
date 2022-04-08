{ pkgs, lib, ... }: {
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    oh-my-zsh = {
      enable = true;
    };
    initExtra = "source ${pkgs.zsh-powerlevel9k}/share/zsh-powerlevel9k/powerlevel9k.zsh-theme";
    plugins = [{
      name = "enhancd";
      file = "init.sh";
      src = pkgs.fetchFromGitHub {
        owner = "b4b4r07";
        repo = "enhancd";
        rev = "v2.2.4";
        sha256 = "1smskx9vkx78yhwspjq2c5r5swh9fc5xxa40ib4753f00wk4dwpp";
      };
    }];
    sessionVariables = {
      LC_ALL = "en_US.UTF-8";
      LANG = "en_US.UTF-8";
      DEFAULT_USER = "dylanj";
      POWERLEVEL9K_SHORTEN_DIR_LENGTH = 1;
      POWERLEVEL9K_SHORTEN_DELIMITER = "";
      POWERLEVEL9K_SHORTEN_STRATEGY = "truncate_from_right";
      POWERLEVEL9K_LEFT_PROMPT_ELEMENTS = [ "context" "dir" "vcs" ];
      POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS = [ "status" "root_indicator" "background_jobs" "history" ];
    };
    shellAliases = lib.mkMerge [
      ({
        gitlog = "git log --oneline --graph --all";
      })
      (lib.optionalAttrs pkgs.stdenv.isLinux {
        "battery" = "cat /sys/class/power_supply/BAT0/capacity";
        "pbcopy" = "xclip -i -selection clipboard";
        "pbpaste" = "xclip -o -selection clipboard";
        "headphones" = "bluetoothctl connect 70:26:05:E0:AC:84 && sleep 2 && bluetoothctl connect 70:26:05:E0:AC:84";
      })
    ];
  };
}
