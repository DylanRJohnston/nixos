{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  imports =
    [
      ./avahi.nix
      ./bluetooth.nix
      ./boot.nix
      ./docker.nix
      ./fonts.nix
      ./hardware-configuration.nix
      ./i18n.nix
      ./networking.nix
      ./nomad.nix
      ./nvidia.nix
      ./packages.nix
      ./persistence.nix
      ./sudo.nix
      ./user.nix
      ./xserver.nix
    ];

  time.timeZone = "Australia/Perth";
  system.stateVersion = "21.11";
}

