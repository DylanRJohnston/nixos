{ arc, darwinAspectTest, ... }:
{
  arc.base.darwin = {
    system.defaults = {
      dock = {
        show-recents = false;
        autohide = true;
        static-only = true;
        wvous-br-corner = 1;
      };

      finder = {
        FXRemoveOldTrashItems = true;
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

  flake.tests.darwin-settings.remove-old-trash-items = darwinAspectTest {
    aspects = [ arc.base ];
    expr = apple: apple.system.defaults.finder.FXRemoveOldTrashItems;
    enabled = true;
    disabled = null;
  };
}
