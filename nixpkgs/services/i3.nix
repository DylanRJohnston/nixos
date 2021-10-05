{ pkgs, lib, ... }:
let
  merge = x: y: x // y;
  pipe = lib.foldl (x: f: f x);
  modifier = "Mod4";
  keybindings = {
    rofi = {
      "${modifier}+d" = "exec ${pkgs.rofi}/bin/rofi -modi run -show run";
      "${modifier}+space" = "exec ${pkgs.rofi}/bin/rofi -modi run -show run";
      "${modifier}+Tab" = "exec ${pkgs.rofi}/bin/rofi -show window";
    };
    lockscreen = {
      "${modifier}+L" = "exec ${../scripts/i3lock-solarized-dark.sh}";
      "${modifier}+Shift+L" = "exec ${../scripts/i3lock-solarized-dark.sh} && systemctl suspend-then-hibernate";
    };
    screenshot = {
      "${modifier}+Shift+s" = "exec flameshot gui";
    };
    i3bar = {
      "${modifier}+b" = "bar mode toggle";
    };
    audioControls = {
      "XF86AudioRaiseVolume" = "exec amixer sset 'Master' 5%+";
      "XF86AudioLowerVolume" = "exec amixer sset 'Master' 5%-";
      "XF86AudioMute" = "exec amixer sset 'Master' toggle";
      "XF86AudioPlay" = "exec playerctl -p spotify play-pause";
      "XF86AudioPause" = "exec playerctl -p spotify play-pause";
      "XF86AudioNext" = "exec playerctl -p spotify next";
      "XF86AudioPrev" = "exec playerctl -p spotify previous";
    };
    brightnessControls = {
      "XF86MonBrightnessUp" = "exec brightnessctl s +10%";
      "XF86MonBrightnessDown" = "exec brightnessctl s 10%-";
    };
  };
in
{
  xsession = {
    enable = true;
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;

      extraConfig = ''
        exec_always autorandr --change
        
        set $mode_gaps Toggle gaps: (1) on (2) off
        bindsym ${modifier}+g mode "$mode_gaps"
        mode "$mode_gaps" {
          bindsym 1 mode "default", gaps inner all set 10, gaps outer all set 0
          bindsym 2 mode "default", gaps inner all set 0, gaps outer all set 0
          bindsym Return mode "default"
          bindsym Escape mode "default"
        }
      '';

      config =
        {
          modifier = modifier;
          bars = [{
            fonts = {
              names = [ "Iosevka, Iosevka Nerd Font" ];
              size = 14.0;
            };
            mode = "hide";
            hiddenState = "hide";
            position = "top";
            statusCommand = "i3status";
            extraConfig = "modifier none";
          }];
          terminal = "alacritty";

          window.border = 0;

          gaps = {
            inner = 0;
            outer = 0;
            smartBorders = "on";
            smartGaps = true;
          };

          keybindings = pipe keybindings [
            lib.attrValues
            (lib.foldl merge { })
            lib.mkOptionDefault
          ];
        };
    };
  };
}
