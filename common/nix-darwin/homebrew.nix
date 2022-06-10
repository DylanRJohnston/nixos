{
  homebrew = {
    enable = true;
    cleanup = "zap";
    taps = [ "homebrew/cask" ];
    autoUpdate = true;
    casks = [
      "1password"
      "alacritty"
      "alfred"
      "discord"
      "docker"
      "firefox"
      "obsidian"
      "omnifocus"
      "rectangle"
      "slack"
    ];
  };
}
