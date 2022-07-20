{
  homebrew = {
    enable = true;
    cleanup = "zap";
    taps = [ "homebrew/cask" ];
    autoUpdate = true;
    casks = [
      "1password"
      "alfred"
      "discord"
      "docker"
      "firefox"
      "obsidian"
      "omnifocus"
      "rectangle"
      "slack"
      "steam"
      "wezterm"
    ];
  };
}
