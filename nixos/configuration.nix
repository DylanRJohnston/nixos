{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  imports =
    [
      ./bluetooth.nix
      ./boot.nix
      ./docker.nix
      ./fonts.nix
      ./hardware-configuration.nix
      ./networking.nix
      ./packages.nix
      ./user.nix
      ./xserver.nix
    ];

  time.timeZone = "Australia/Perth";
  system.stateVersion = "21.11";
}

