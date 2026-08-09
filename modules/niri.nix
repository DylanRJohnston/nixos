{ arc, lib, ... }:
{
  arc.interactive.includes = [
    arc.interactive._.niri
    arc.interactive._.noctalia
  ];

  arc.interactive._.noctalia.nixos = {
    programs.noctalia = {
      enable = true;
      recommendedServices.enable = true;
      systemd.enable = true;
    };
  };

  arc.interactive._.niri = {
    nixos =
      { config, ... }:
      {
        programs.niri.enable = true;
        programs.ssh.startAgent = lib.mkForce false;

        services.greetd = {
          enable = true;
          settings.default_session = {
            user = "dylanj";
            command = "${config.programs.niri.package}/bin/niri-session";
          };
        };

        # Prevent NixOS from injecting a stripped PATH into the niri.service
        # unit, which would shadow the full PATH imported by niri-session.
        systemd.user.services.niri.enableDefaultPath = false;
      };

    homeManager =
      { lib, pkgs, ... }:
      {
        home.file.".config/niri/config.kdl".text = lib.hm.generators.toKDL { } {
          xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

          input.keyboard.xkb.layout = "us,ua";

          layout.gaps = 5;

          binds = {

            "Mod+Shift+Slash".show-hotkey-overlay = { };
            "Mod+Return hotkey-overlay-title=\"Open a Terminal: Wezterm\"".spawn-sh = lib.getExe pkgs.wezterm;

            "Mod+O repeat=false".toggle-overview = { };
            "Mod+Q repeat=false".close-window = { };
            "Mod+Space".spawn-sh = "${lib.getExe pkgs.noctalia} msg panel-toggle launcher";

            "Mod+Left".focus-column-left = { };
            "Mod+Right".focus-column-right = { };
            "Mod+Up".focus-window-up = { };
            "Mod+Down".focus-window-down = { };

            "Mod+WheelScrollDown cooldown-ms=150".focus-workspace-down = { };
            "Mod+WheelScrollUp   cooldown-ms=150".focus-workspace-up = { };
            "Mod+WheelScrollRight".focus-column-right = { };
            "Mod+WheelScrollLeft".focus-column-left = { };
            "Mod+Ctrl+WheelScrollRight".move-column-right = { };
            "Mod+Ctrl+WheelScrollLeft".move-column-left = { };

            "Mod+Ctrl+Left".move-column-left = { };
            "Mod+Ctrl+Right".move-column-right = { };
            "Mod+Ctrl+Up".move-window-up = { };
            "Mod+Ctrl+Down".move-window-down = { };

            "Mod+Home".focus-column-first = { };
            "Mod+Ctrl+Home".move-column-to-first = { };
            "Mod+End".focus-column-last = { };
            "Mod+Ctrl+End".move-column-to-last = { };

            "Mod+Shift+Left".focus-monitor-left = { };
            "Mod+Shift+Down".focus-monitor-down = { };
            "Mod+Shift+Up".focus-monitor-up = { };
            "Mod+Shift+Right".focus-monitor-right = { };

            "Mod+Shift+Ctrl+Left".move-column-to-monitor-left = { };
            "Mod+Shift+Ctrl+Down".move-column-to-monitor-down = { };
            "Mod+Shift+Ctrl+Up".move-column-to-monitor-up = { };
            "Mod+Shift+Ctrl+Right".move-column-to-monitor-right = { };

            "Mod+1"."focus-workspace 1" = { };
            "Mod+2"."focus-workspace 2" = { };
            "Mod+3"."focus-workspace 3" = { };
            "Mod+4"."focus-workspace 4" = { };
            "Mod+5"."focus-workspace 5" = { };
            "Mod+6"."focus-workspace 6" = { };
            "Mod+7"."focus-workspace 7" = { };
            "Mod+8"."focus-workspace 8" = { };
            "Mod+9"."focus-workspace 9" = { };
            "Mod+Ctrl+1"."move-column-to-workspace 1" = { };
            "Mod+Ctrl+2"."move-column-to-workspace 2" = { };
            "Mod+Ctrl+3"."move-column-to-workspace 3" = { };
            "Mod+Ctrl+4"."move-column-to-workspace 4" = { };
            "Mod+Ctrl+5"."move-column-to-workspace 5" = { };
            "Mod+Ctrl+6"."move-column-to-workspace 6" = { };
            "Mod+Ctrl+7"."move-column-to-workspace 7" = { };
            "Mod+Ctrl+8"."move-column-to-workspace 8" = { };
            "Mod+Ctrl+9"."move-column-to-workspace 9" = { };

            "Mod+BracketLeft".consume-or-expel-window-left = { };
            "Mod+BracketRight".consume-or-expel-window-right = { };

            "Mod+Comma".consume-window-into-column = { };
            "Mod+Period".expel-window-from-column = { };

            "Mod+R".switch-preset-column-width = { };
            "Mod+Shift+R".switch-preset-column-width-back = { };

            "Mod+Ctrl+Shift+R".switch-preset-window-height = { };
            "Mod+Ctrl+R".reset-window-height = { };

            "Mod+F".maximize-column = { };
            "Mod+Shift+F".fullscreen-window = { };

            "Mod+M".maximize-window-to-edges = { };
            "Mod+Ctrl+F".expand-column-to-available-width = { };
            "Mod+C".center-column = { };

            "Mod+Ctrl+C".center-visible-columns = { };

            "Mod+Minus"."set-column-width \"-10%\"" = { };
            "Mod+Equal"."set-column-width \"+10%\"" = { };

            "Mod+Shift+Minus"."set-window-height \"-10%\"" = { };
            "Mod+Shift+Equal"."set-window-height \"+10%\"" = { };

            "Mod+V".toggle-window-floating = { };
            "Mod+Shift+V".switch-focus-between-floating-and-tiling = { };

            "Mod+W".toggle-column-tabbed-display = { };

            "Mod+Shift+E".quit = { };
            "Ctrl+Alt+Delete".quit = { };

            "Mod+Shift+P".power-off-monitors = { };
          };
        };
      };
  };
}
