{ pkgs, ... }:

{
  imports = [
    ./packages.nix
    ./config
  ];

  programs.home-manager = {
    enable = true;
    path = "…";
  };
}
