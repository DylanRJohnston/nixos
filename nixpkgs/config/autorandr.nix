{ lib, ... }:
let
  internalDisplay = { "eDP-1" = "*8a"; };
  externalMonitor = { "DP-1-2" = "*d5"; };
  displays = lib.genAttrs [ "DP-1" "DP-2" "DP-3" "DP-1-1" "DP-1-2" "DP-1-3" "HDMI-1" "HDMI-2" "eDP-1" ] (_: { enable = false; });
in
{
  programs.autorandr = {
    enable = true;

    hooks.postswitch.change-background = "feh --bg-scale ~/Pictures/background.png";

    profiles = {
      "undocked" = {
        fingerprint = internalDisplay;
        config = displays // {
          "eDP-1" = {
            enable = true;
            crtc = 1;
            mode = "1920x1080";
            position = "0x0";
            rate = "60.00";
          };
        };
      };
      "docked" = {
        fingerprint = internalDisplay // externalMonitor;
        config = displays // {
          "DP-1-2" = {
            enable = true;
            crtc = 0;
            mode = "3440x1440";
            position = "0x0";
            primary = true;
            rate = "59.97";
          };
        };
      };
    };
  };
}
