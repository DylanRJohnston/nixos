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
      "obsidian"
      "omnifocus"
      "rectangle"
    ];
  };
}
