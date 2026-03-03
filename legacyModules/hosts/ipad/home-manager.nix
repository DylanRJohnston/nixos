{ pkgs, ... }:
{
  custom = {
    gpg-agent.enable = true;
    i3.enable = true;
  };

  programs.firefox.enable = true;
  programs.rofi.enable = true;
}
