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
      "docker"
      "firefox"
      "microsoft-teams"
      "obsidian"
      "omnifocus"
      "rectangle"
    ];
  };
}
