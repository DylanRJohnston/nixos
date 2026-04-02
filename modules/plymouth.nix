{ arc, ... }:
{
  arc.entertainment.includes = [ arc.entertainment._.plymouth ];

  arc.entertainment._.plymouth =
    { pkgs, ... }:
    {
      systemd.services.systemd-vconsole-setup.enable = false;
      boot = {
        plymouth =
          let
            theme = "cross_hud";
          in
          {
            enable = true;
            theme = theme;
            themePackages = with pkgs; [
              # By default we would install all themes
              (adi1090x-plymouth-themes.override {
                selected_themes = [ theme ];
              })
            ];
          };

        # Enable "Silent boot"
        consoleLogLevel = 3;
        initrd.verbose = false;
        kernelParams = [
          "quiet"
          "udev.log_level=3"
          "systemd.show_status=auto"
          "vt.global_cursor_default=0"
        ];
        # Hide the OS choice for bootloaders.
        # It's still possible to open the bootloader list by pressing any key
        # It will just not appear on screen unless a key is pressed
        loader.timeout = 1;

        initrd = {
          systemd.enable = true;
        };

        loader.systemd-boot.consoleMode = "1";
      };

      console = {
        earlySetup = true;
        packages = [ pkgs.terminus_font ];
        keyMap = "us";
      };
    };
}
