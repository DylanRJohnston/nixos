{
  system.defaults = {
    dock = {
      show-recents = false;
      autohide = true;
    };

    NSGlobalDomain = {
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      AppleKeyboardUIMode = 3;

      "com.apple.sound.beep.feedback" = 0;

      AppleShowAllExtensions = true;
      AppleInterfaceStyle = "Dark";
      _HIHideMenuBar = false;
    };
  };

  # Setup system hotkeys
  system.activationScripts.userDefaults.text = ''
    defaults import com.apple.symbolichotkeys ${./plists/symbolichotkeys.plist}
    sudo /usr/sbin/nvram StartupMute=%01
  '';
}
