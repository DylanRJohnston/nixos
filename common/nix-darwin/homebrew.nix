{
  homebrew = {
    enable = true;
    cleanup = "zap";
    taps = [ "homebrew/cask" ];
    autoUpdate = true;
    casks = [
      "1password"
      "alfred"
      "dbeaver-community"
      "discord"
      "docker"
      "firefox"
      "google-chrome"
      "istat-menus"
      "obsidian"
      "omnifocus"
      "postman"
      "rectangle"
      "signal"
      "slack"
      "steam"
      "wezterm"
    ];
  };
}
