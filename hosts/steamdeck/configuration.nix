{ common, pkgs, modules, lib, ... }: {
  imports = [
    modules.jovian
    modules.steam-compat

    common.fonts
    # common.nix-build
    common.nix-config
    common.openssh
    common.user
    common.vscode-server
    common.wifi
    common.zsh

    ./hardware-configuration.nix
  ];

  nixpkgs.overlays = [
    (next: prev: {
      decky-loader = prev.decky-loader.overrideAttrs (old: {
        patches = old.patches ++ [ ../../patches/decky-debug.patch ];
      });
    })
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  services.xserver.desktopManager.gnome.enable = true;
  hardware.pulseaudio.enable = lib.mkForce false;

  jovian = {
    steam = {
      enable = true;
      autoStart = true;
      user = "dylanj";
      desktopSession = "gnome";
    };

    devices.steamdeck.enable = true;

    decky-loader = {
      enable = true;
      user = "dylanj";
    };
  };

  environment.systemPackages = with pkgs; [
    gnomeExtensions.dash-to-dock
    jupiter-dock-updater-bin
    steamdeck-firmware
    jupiter-hw-support
    git
    vim
    moonlight-qt
    python3
  ];

  programs.steam = {
    enable = true;
    extraCompatPackages = [ pkgs.proton-ge ];
  };

  system.stateVersion = "23.11";
  hardware.steam-hardware.enable = true;
  services.joycond.enable = true;
  # boot.blacklistedKernelModules = [ "hid-nintendo" ];

  #hardware.bluetooth.package = pkgs.bluez.overrideAttrs (old: {
  #   patches = old.patches ++ [
  #     (pkgs.fetchpatch {
  #       url = "https://github.com/bluez/bluez/commit/3a9c637010f8dc1ba3e8382abe01065761d4f5bb.patch";
  #       hash = "sha256-UUmYMHnxYrw663nEEC2mv3zj5e0omkLNejmmPUtgS3c=";
  #     })
  #   ];
  # });
}
