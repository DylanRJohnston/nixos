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
        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = true;
          gtk-cursor-theme-name = "steam";
        };
      };

      xdg.configFile."gtk-3.0/settings.ini".force = true;
    };
  };

  flake.tests.darkmode = nixosAspectTest {
    baseline = [ arc.base ];
    aspects = [ arc.interactive ];
    expr = igloo: {
      qt = igloo.qt.enable;
      colorScheme =
        igloo.home-manager.users.tux.dconf.settings."org/gnome/desktop/interface".color-scheme;
      gtkDark = igloo.home-manager.users.tux.gtk.gtk3.extraConfig.gtk-application-prefer-dark-theme;
      gtkSettingsForce = igloo.home-manager.users.tux.xdg.configFile."gtk-3.0/settings.ini".force;
    };
    enabled = {
      qt = true;
      colorScheme = "prefer-dark";
      gtkDark = true;
      gtkSettingsForce = true;
    };
    disabledErr.msg = "attribute.*missing";
  };
}
