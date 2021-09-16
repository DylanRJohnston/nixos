{ pkgs, ... }: {
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
      DEFAULT_USER = "dylanj";
      POWERLEVEL9K_SHORTEN_DIR_LENGTH = 1;
      POWERLEVEL9K_SHORTEN_DELIMITER = "";
      POWERLEVEL9K_SHORTEN_STRATEGY = "truncate_from_right";
      POWERLEVEL9K_LEFT_PROMPT_ELEMENTS = [ "context" "dir" "vcs" ];
      POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS = [ "status" "root_indicator" "background_jobs" "history" ];
    };
  };
}
