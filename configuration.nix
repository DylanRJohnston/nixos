{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  imports =
    [
      ./bluetooth.nix
      ./boot.nix
      ./docker.nix
      ./flakes.nix
      ./fonts.nix
      ./hardware-configuration.nix
      ./i18n.nix
      ./networking.nix
      ./nvidia.nix
      ./packages.nix
      ./user.nix
      ./xserver.nix
    ];

  time.timeZone = "Australia/Perth";
  system.stateVersion = "21.11";
}

