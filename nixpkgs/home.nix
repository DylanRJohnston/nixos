{ pkgs, ... }:

{
  imports = [ ./packages.nix ./git.nix ./autorandr.nix ./i3.nix  ./compton.nix ./polybar.nix ./rofi.nix ];

  programs.home-manager = {
    enable = true;
    path = "…";
  };
}
