{ arc, unitTest, ... }:
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

  flake.tests.darkmode = {
    test-interactive-host = unitTest (
      { arc, igloo, ... }:
      {
        den.hosts.x86_64-linux.igloo = {
          users.tux = { };
          aspects = with arc; [
            base
            interactive
          ];
        };

        expr = igloo.qt.enable;
        expected = true;
      }
    );

    test-headless-host = unitTest (
      { arc, igloo, ... }:
      {
        den.hosts.x86_64-linux.igloo = {
          users.tux = { };
          aspects = [ arc.base ];
        };

        expr = igloo.qt.enable;
        expected = false;
      }
    );
  };
}
