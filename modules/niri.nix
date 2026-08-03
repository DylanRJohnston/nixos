{ arc, ... }:
{
  arc.interactive.includes = [ arc.interactive._.niri ];
  arc.interactive._.niri = {
    nixos.programs.niri.enable = true;
    homeManager =
      { lib, pkgs, ... }:
      {
        home.file.".config/niri/config.kdl".text = lib.hm.generators.toKDL { } {
          spawn-at-startup = [
            (lib.getExe pkgs.noctalia-shell)
          ];

          xwayland-satellite.path = lib.getExe pkgs.wayland-sattelite;

          input.keyboard.xkb.layout = "us,ua";

          layout.gaps = 5;

          binds = {
            "Mod+Return".spawn-sh = lib.getExe pkgs.wezterm;
            "Mod+Q".close-window = null;
            "Mod+S".spwan-sh = "${lib.getExe pkgs.noctalia-shell} ipc call launcher toggle";
          };
        };
      };
  };
}
