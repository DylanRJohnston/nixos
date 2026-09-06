{ arc, nixosAspectTest, ... }:
{
  arc.interactive.includes = [ arc.interactive._.darkmode ];

  arc.interactive._.darkmode = {
    nixos.qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };

    homeManager = {
      dconf.settings."org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = "Adwaita-dark";
      };

      gtk = {
        enable = true;
        gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
      };
    };
  };

  flake.tests.darkmode = nixosAspectTest {
    baseline = [ arc.base ];
    aspects = [ arc.interactive ];
    expr = igloo: igloo.qt.enable;
    enabled = true;
    disabled = false;
  };
}
