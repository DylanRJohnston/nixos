{ pkgs, ... }:

{
  home.packages = with pkgs; [
    htop
    fortune
    google-chrome
    _1password
    vim
    tmux
    vscode
    feh
    git
    alacritty
  ];

  programs.git = {
    enable = true;
    userName = "Dylan R. Johnston";
    userEmail = "dylan.r.johnston@gmail.com";
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };

  programs.home-manager = {
    enable = true;
    path = "…";
  };

  programs.autorandr = {
    enable = true;
    profiles = {
      "undocked" = {
        fingerprint = {
          "eDP-1" = "00ffffffffffff0009e5bc0700000000121c0104951f1178020ea0a657529f2710505400000001010101010101010101010101010101d93880b470384b403020360035ad1000001a00000000000000000000000000000000001a000000fe003333385847804e4531344e343400000000000041019e001000000a010a2020008a";
        };
        config = {
          "eDP-1" = {
            enable = true;
            crtc = 0;
            primary = true;
            position = "0x0";
            mode = "1920x180";
            rate = "60.00";
          };
        };
      };
      "docked" = {
        fingerprint = {
          "eDP-1" = "00ffffffffffff0009e5bc0700000000121c0104951f1178020ea0a657529f2710505400000001010101010101010101010101010101d93880b470384b403020360035ad1000001a00000000000000000000000000000000001a000000fe003333385847804e4531344e343400000000000041019e001000000a010a2020008a";
          "DP-1-2" = "00ffffffffffff0010ac81a14c413430271e0104b55021783e5d15ae4f44ab270e5054a54b00714f81008180a940d1c0010101010101e77c70a0d0a0295030203a00204f3100001a000000ff0043485a4b3635330a2020202020000000fc0044454c4c20553334323157450a000000fd0030551e5920010a202020202020012a02031df1509005040302071601141f1213454b4c5a2309070783010000565e00a0a0a0295030203500204f3100001a584d00b8a1381440942cb500204f3100001e3c41b8a060a029505020ca04204f3100001a023a801871382d40582c4500204f3100001e0000000000000000000000000000000000000000000000000000d5";
        };
        config = {
          "eDP-1" = { enable = false; };
          "DP-1-2" = {
            enable = true;
            crtc = 0;
            primary = true;
            position = "0x0";
            mode = "3440x1440";
            rate = "60.00";
          };
        };
      };
    };
  };

  xsession.enable = true;
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;

    extraConfig = ''
      bindsym Mod4+L exec $HOME/.config/nixpkgs/scripts/i3lock-solarized-dark.sh
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
    };
  };
}
