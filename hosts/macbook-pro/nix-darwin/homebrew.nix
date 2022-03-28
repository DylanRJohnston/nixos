{
  homebrew = {
    enable = true;
    cleanup = "zap";
    taps = [ "homebrew/cask" ];
    casks = [
      "1password"
      "alacritty"
      "firefox"
      "microsoft-teams"
      "obsidian"
      "omnifocus"
    ];
  };
}
