{ pkgs, ... }:

{
  imports = [
    ./packages.nix
    ./config
    ./services
  ];

  programs.home-manager = {
    enable = true;
    path = "…";
  };
}
