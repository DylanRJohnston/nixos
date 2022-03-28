{ config, pkgs, ... }:

{
  imports = [
    ./apps.nix
    ./fonts.nix
    ./nix-config.nix
    ./system-defaults.nix
    ./system-packages.nix
    ./touchID.nix
  ];

  programs.zsh.enable = true; # default shell on catalina

  system.stateVersion = 4;
}
