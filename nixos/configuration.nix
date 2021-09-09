{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  imports =
    [
      ./hardware-configuration.nix
      ./boot.nix
      ./user.nix
      ./networking.nix
      ./bluetooth.nix
      ./xserver.nix
      ./packages.nix
    ];

  time.timeZone = "Australia/Perth";
  system.stateVersion = "21.11";
}

