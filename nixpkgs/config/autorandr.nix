{
  programs.autorandr = {
    enable = true;

    hooks.postswitch.change-background = "feh --bg-scale ~/Pictures/background.png";
    hooks.postswitch.restart-polybar = "systemctl --user restart polybar.service";

    profiles =
      let
        internalFingerprint = "00ffffffffffff0009e5bc0700000000121c0104951f1178020ea0a657529f2710505400000001010101010101010101010101010101d93880b470384b403020360035ad1000001a00000000000000000000000000000000001a000000fe003333385847804e4531344e343400000000000041019e001000000a010a2020008a";
        externalMonitor = "00ffffffffffff0010ac81a14c413430271e0104b55021783e5d15ae4f44ab270e5054a54b00714f81008180a940d1c0010101010101e77c70a0d0a0295030203a00204f3100001a000000ff0043485a4b3635330a2020202020000000fc0044454c4c20553334323157450a000000fd0030551e5920010a202020202020012a02031df1509005040302071601141f1213454b4c5a2309070783010000565e00a0a0a0295030203500204f3100001a584d00b8a1381440942cb500204f3100001e3c41b8a060a029505020ca04204f3100001a023a801871382d40582c4500204f3100001e0000000000000000000000000000000000000000000000000000d5";
      in
      {
        "undocked" = {
          fingerprint = {
            "eDP-1" = internalFingerprint;
          };
          config = {
            "DP-1".enable = false;
            "DP-2".enable = false;
            "DP-3".enable = false;
            "DP-1-1".enable = false;
            "DP-1-2".enable = false;
            "DP-1-3".enable = false;
            "HDMI-1".enable = false;
            "HDMI-2".enable = false;
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
          fingerprint = {
            "eDP-1" = internalFingerprint;
            "DP-1-2" = externalMonitor;
          };
          config = {
            "eDP-1".enable = false;
            "DP-1".enable = false;
            "DP-2".enable = false;
            "DP-3".enable = false;
            "DP-1-1".enable = false;
            "DP-1-3".enable = false;
            "HDMI-1".enable = false;
            "HDMI-2".enable = false;
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