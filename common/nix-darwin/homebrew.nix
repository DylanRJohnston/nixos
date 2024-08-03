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
      "audacity"
      "backblaze"
      "caffeine"
      "cyberduck"
      "dbeaver-community"
      "discord"
      "docker"
      "firefox"
      "gimp"
      "google-chrome"
      "istat-menus"
      "jellyfin"
      "obsidian"
      "omnifocus"
      "openmtp"
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
