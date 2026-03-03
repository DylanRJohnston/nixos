{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.custom.desktop;
in
{
  options.custom.desktop = {
    enable = lib.mkEnableOption "Enable sway desktop";

    idle = {
      lockTimeout = lib.mkOption {
        type = lib.types.int;
        default = 300;
        description = "Time in seconds before locking the screen";
      };

      displayTimeout = lib.mkOption {
        type = lib.types.int;
        default = 600;
        description = "Time in seconds before turning off displays";
      };

      suspendTimeout = lib.mkOption {
        type = lib.types.int;
        default = 900;
        description = "Time in seconds before suspending the system";
      };
    };

    launcher = lib.mkOption {
      type = lib.types.str;
      default = "${pkgs.rofi-wayland}/bin/rofi -show drun";
    };

    lock = {
      blurEffect = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable blur effect on lock screen";
      };

      showClock = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show clock on lock screen";
      };

      showIndicator = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show typing indicator on lock screen";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.dbus.enable = true;
    programs.sway.enable = true;
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    };

    # Install swaylock and swayidle for idle/sleep/lock functionality
    environment.systemPackages = with pkgs; [
      swaylock-effects # Enhanced swaylock with blur and other effects
      swayidle
      rofi
      wezterm
    ];

    # Enable swaylock PAM service for authentication
    security.pam.services.swaylock = { };

    # Sway configuration with idle management
    programs.sway = {
      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [
        swaylock-effects
        swayidle
        grim # For screenshots
        slurp # For screen selection
        rofi
      ];
    };

    # environment.etc."sway/config".text = ''
    #   set $menu ${cfg.launcher}
    #   bindsym $mod+space exec $menu
    # '';

    services.greetd =
      let
        # Small wrapper so greetd launches a predictable environment and logs crashes.
        swayRun = pkgs.writeShellScriptBin "sway-run" ''
          set -euo pipefail

          # Log to the journal (view with: journalctl -t sway-run -b)
          exec 1> >(systemd-cat -t sway-run) 2>&1

          export XDG_SESSION_TYPE=wayland
          export XDG_CURRENT_DESKTOP=sway
          export XDG_CURRENT_DESKTOP=sway
          export SDL_VIDEODRIVER=wayland
          export MOZ_ENABLE_WAYLAND=1

          # If you use a specific terminal/launcher, set it here if you want:
          # export TERMINAL=foot

          # Create swaylock command with configurable options
          swaylock_cmd="${pkgs.swaylock-effects}/bin/swaylock -f${lib.optionalString cfg.lock.showClock " --clock"}${lib.optionalString cfg.lock.showIndicator " --indicator"}${lib.optionalString cfg.lock.blurEffect " --effect-blur 7x5"} --fade-in 0.2"

          # Start swayidle with configurable timeouts
          ${pkgs.swayidle}/bin/swayidle -w \
            timeout ${toString cfg.idle.lockTimeout} "$swaylock_cmd" \
            timeout ${toString cfg.idle.displayTimeout} 'swaymsg "output * dpms off"' \
            resume 'swaymsg "output * dpms on"' \
            timeout ${toString cfg.idle.suspendTimeout} 'systemctl suspend' \
            before-sleep "$swaylock_cmd" \
            after-resume 'swaymsg "output * dpms on"' &

          exec ${pkgs.sway}/bin/sway --unsupported-gpu
        '';
      in
      {
        enable = true;
        settings = {
          default_session = {
            user = "dylanj";
            command = "${swayRun}/bin/sway-run";
          };
        };
      };
  };
}
