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
      "cyberduck"
      "dbeaver-community"
      "discord"
      "docker"
      "firefox"
      "gimp"
      "google-chrome"
      "istat-menus"
      "obsidian"
      "omnifocus"
      "postman"
      "rectangle"
      "signal"
      "slack"
      "steam"
      "transmission"
      "visual-studio-code"
      "vlc"
      "wezterm"
      "wireshark"
    ];
  };
}
