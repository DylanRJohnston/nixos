{
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
    };

    # taps = [ "homebrew/cask" ];
    casks = [
      "1password"
      "alfred"
      "caffeine"
      "dbeaver-community"
      "docker-desktop"
      "firefox"
      "google-chrome"
      "istat-menus"
      "microsoft-teams"
      "obsidian"
      "omnifocus"
      "postman"
      "rectangle"
      "spotify"
      "wezterm"
      "wireshark-app"
      "zed"
    ];
  };
}
