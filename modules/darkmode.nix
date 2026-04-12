{ arc, ... }:
{
  arc.base.includes = [ arc.base._.darkmode ];

  arc.base._.darkmode.nixos.qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };
}
