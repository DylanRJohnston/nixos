{ lib, config, ... }:
{
  options.custom.homebrew.enable = lib.mkEnableOption "Enable Homebrew Config";

  config = lib.mkIf config.custom.homebrew.enable {
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
        "wezterm"
        "wireshark-app"
        "zed"
      ];
    };
  };
}
