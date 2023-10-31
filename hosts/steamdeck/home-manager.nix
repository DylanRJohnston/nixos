{ pkgs, common, ... }: {
  imports = with common; [
    base
  ];

  programs.firefox.enable = true;

  dconf.settings = {
      "org/gnome/desktop/a11y/applications" = {
        screen-keyboard-enabled = true;
      };
      "org/gnome/shell" = {
        favourite-apps = [ "steam.desktop" ];
      };
    };
}
