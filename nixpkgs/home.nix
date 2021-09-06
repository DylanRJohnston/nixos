{ pkgs, ... }:

{
  imports = [ ./packages.nix ./git.nix ./autorandr.nix ./i3.nix ];

  programs.home-manager = {
    enable = true;
    path = "…";
  };
}
