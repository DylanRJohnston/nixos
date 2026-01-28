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
  options.custom.desktop.enable = lib.mkEnableOption "Enable sway desktop";

  config = lib.mkIf cfg.enable {
    services.dbus.enable = true;
    programs.sway.enable = true;
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    };

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

          exec ${pkgs.sway}/bin/sway
        '';
      in
      {
        enable = true;
        settings = {
          default_session = {
            user = "dylanj";
            command = "${swayRun}/bin/sway";
          };
        };
      };
  };
}
