{
  homebrew = {
    enable = true;
    cleanup = "zap";
    taps = [ "homebrew/cask" ];
    autoUpdate = true;
    casks = [
      "1password"
      "alacritty"
      "docker"
      "firefox"
      "microsoft-teams"
      "obsidian"
      "omnifocus"
      "rectangle"
    ];
  };
}
