{
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
    };
    taps = [ "homebrew/cask" ];
    casks = [
      "1password"
      "alfred"
      "dbeaver-community"
      "discord"
      "docker"
      "firefox"
      "google-chrome"
      "gimp"
      "istat-menus"
      "obsidian"
      "omnifocus"
      "postman"
      "rectangle"
      "signal"
      "slack"
      "steam"
      "wezterm"
      "wireshark"
      "transmission"
      "visual-studio-code"
      "vlc"
    ];
  };
}
