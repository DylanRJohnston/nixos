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

  nixpkgs.overlays = [(
    next: prev: {
      decky-loader = prev.decky-loader.overrideAttrs (old: {
        src = prev.fetchFromGitHub {
          owner = "DylanRJohnston-FZ";
          repo = "decky-loader";
          rev = "e65efa8326e99b21c5e55e709bf65f6708b61d92";
          hash = "sha256-h7v3DTpAtyZGNrJqcthrlLKJFyfZIVvbckj8mMNMwnE=";
        };
        patches = [];
      });
    }
  )];

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

  programs.steam.enable = true;

  system.stateVersion = "23.11";
}
