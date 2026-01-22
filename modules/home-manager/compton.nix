# credits: @LightDiscord who helped me to update to picom
{
  lib,
  config,
  ...
}:
{

  options.custom.compton.enable = lib.mkEnableOption "Enable compton";

  config.services.picom = lib.mkIf config.custom.compton.enable {
    enable = true;

    # blur = true;
    # blurExclude = [ "window_type = 'dock'" "window_type = 'desktop'" ];

    fade = false;

    shadow = true;
    shadowOffsets = [
      (-7)
      (-7)
    ];
    shadowOpacity = 0.7;
    shadowExclude = [ "window_type *= 'normal' && ! name ~= ''" ];

    activeOpacity = 1.0;
    inactiveOpacity = 0.9;
    menuOpacity = 0.8;

    backend = "xrender";
    vSync = true;

    settings = {
      frame-opacity = 0.7;
      mark-overdir-focused = true;
      blur = {
        method = "gaussian";
        size = 10;
        deviation = 10.0;
      };
    };
  };
}
