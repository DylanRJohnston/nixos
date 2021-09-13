{ pkgs, ... }:

{
  imports = [
    ./packages.nix
    ./git.nix
    ./autorandr.nix
    ./i3.nix
    ./compton.nix
    ./polybar/default.nix
    ./rofi.nix
    ./vscode.nix
  ];

  programs.home-manager = {
    enable = true;
    path = "…";
  };
}
