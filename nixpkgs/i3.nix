{ pkgs, lib, ... }: {
  xsession = {
    enable = true;
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;

      extraConfig = ''
        exec_always autorandr --change
        exec_always --no-startup-id sleep 5 && feh --bg-center --no-xinerama $HOME/Pictures/background.png
      '';

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
        };
      };
    };
  };
}
