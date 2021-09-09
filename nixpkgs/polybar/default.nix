{ pkgs, ... }:
let
  # foo = "bar";
  # bars = builtins.readFile ./bars.ini;
  # colors = builtins.readFile ./colors.ini;
  # mods1 = builtins.readFile ./modules.ini;
  # mods2 = builtins.readFile ./user_modules.ini;
in
{
  services.polybar = {
    enable = true;

    package = pkgs.polybar.override {
      i3GapsSupport = true;
      alsaSupport = true;
      pulseSupport = true;
    };

    script = "polybar -q -r top &";

    config = ./config.ini;
    # extraConfig = bars + colors + mods1 + mods2;
  };
}
