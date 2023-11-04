{ common, pkgs, modules, lib, ... }: {
  imports = with common; [
    user
    modules.jovian
    wifi
    fonts
    nix-config
    zsh
    vscode-server
    openssh
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;

  services.xserver.desktopManager.gnome.enable = true;
  hardware.pulseaudio.enable = lib.mkForce false;

  jovian = {
    steam.enable = true;
    steam.autoStart = true;
    steam.user = "dylanj";
    steam.desktopSession = "gnome-wayland"; 
    devices.steamdeck.enable = true;
    decky-loader.enable = true;
  };

  environment.systemPackages = with pkgs; [
    gnomeExtensions.dash-to-dock
    jupiter-dock-updater-bin
    steamdeck-firmware
    jupiter-hw-support
    git
    vim
    moonlight-qt
  ];

  programs.steam.enable = true;

  system.stateVersion = "23.11";
}
