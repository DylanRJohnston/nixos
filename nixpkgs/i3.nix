{ pkgs, lib, ... }: {
  xsession = {
    enable = true;
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;

      extraConfig = "exec_always autorandr --change";

      config = rec {
        modifier = "Mod4";
        bars = [ ];
        terminal = "alacritty";

        window.border = 0;

        gaps = {
          inner = 15;
          outer = 0;
        };

        keybindings = lib.mkOptionDefault {
          "${modifier}+L" = "exec $HOME/.config/nixpkgs/scripts/i3lock-solarized-dark.sh";
          "${modifier}+Shift+s" = "exec flameshot gui";
          "${modifier}+d" = "exec ${pkgs.rofi}/bin/rofi -modi run -show run";
          "${modifier}+space" = "exec ${pkgs.rofi}/bin/rofi -modi run -show run";
          "${modifier}+Tab" = "exec ${pkgs.rofi}/bin/rofi -show window";
          "XF86AudioRaiseVolume" = "exec amixer sset 'Master' 5%+";
          "XF86AudioLowerVolume" = "exec amixer sset 'Master' 5%-";
          "XF86AudioMute" = "exec amixer sset 'Master' toggle";
          "XF86AudioPlay" = "exec playerctl -p spotify play-pause";
          "XF86AudioPause" = "exec playerctl -p spotify play-pause";
          "XF86AudioNext" = "exec playerctl -p spotify next";
          "XF86AudioPrev" = "exec playerctl -p spotify previous";
        };

      };
    };
  };
}
