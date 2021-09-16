{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    oh-my-zsh = {
      enable = true;
      theme = "agnoster";
    };
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
  };
}
