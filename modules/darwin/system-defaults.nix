{ lib, config, ... }:
{
  options.custom.system-defaults.enable = lib.mkEnableOption "Enable system defaults";

  config = lib.mkIf config.custom.system-defaults.enable {
    system.defaults = {
      dock = {
        show-recents = false;
        autohide = true;
        # persistent-apps = [ ];
        # persistent-others = [ ];
        static-only = true;
      };

      finder = {
        ShowPathbar = true;
      };

      universalaccess = {
        closeViewScrollWheelToggle = true;
      };

      NSGlobalDomain = {
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        AppleKeyboardUIMode = 3;

        "com.apple.sound.beep.feedback" = 0;

        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        AppleInterfaceStyle = "Dark";
        _HIHideMenuBar = false;
      };

      WindowManager = {
        EnableStandardClickToShowDesktop = false;
        StandardHideDesktopIcons = true;
        StandardHideWidgets = true;
      };

      controlcenter = {
        BatteryShowPercentage = true;
      };
    };

    # Setup system hotkeys
    system.activationScripts.userDefaults.text = ''
      defaults import com.apple.symbolichotkeys ${./plists/symbolichotkeys.plist}
      sudo /usr/sbin/nvram StartupMute=%01
    '';
  };
}
