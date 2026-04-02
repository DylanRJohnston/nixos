{ arc, ... }:
{
  arc.gaming._.sunshine = {
    includes = [ arc.gaming._.sunshine._.headless ];

    _.headless.nixos.services.sunshine.global_prep_cmd =
      let
        headless.enable = "swaymsg output HEADLESS-1 enable";
        headless.disable = "swaymsg output HEADLESS-1 disable";
        headless.set = "swaymsg output HEADLESS-1 mode \${SUNSHINE_CLIENT_WIDTH}x\${SUNSHINE_CLIENT_HEIGHT}@\${SUNSHINE_CLIENT_FPS}Hz";

        monitor.enable = "swaymsg output DP-1 enable";
        monitor.disable = "swaymsg output DP-1 disable";
      in
      [
        # Need to be careful to keep at least one display enabled at all times
        {
          do = "sh -c \"${headless.enable}; ${headless.set}; ${monitor.disable}\"";
          undo = "sh -c \"${monitor.enable}; ${headless.disable}\"";
        }
      ];
  };
}
