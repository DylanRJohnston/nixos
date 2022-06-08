{ pkgs, common, ... }: {
  imports = with common; [
    base
    gpg-agent
    i3
  ];

  programs.firefox.enable = true;
  programs.rofi.enable = true;
}
