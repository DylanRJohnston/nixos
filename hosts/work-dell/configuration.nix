{ common, config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  imports = [
    ./modules/avahi.nix
    ./modules/bluetooth.nix
    ./modules/boot.nix
    ./modules/docker.nix
    ./modules/hardware-configuration.nix
    ./modules/i18n.nix
    ./modules/networking.nix
    ./modules/nomad.nix
    ./modules/nvidia.nix
    ./modules/packages.nix
    ./modules/persistence.nix
    ./modules/sudo.nix
    ./modules/tailscale.nix
    common.fonts
    common.user
    common.xserver
  ];

  services.fstrim.enable = true;

  time.timeZone = "Australia/Perth";
  system.stateVersion = "25.05";
}

