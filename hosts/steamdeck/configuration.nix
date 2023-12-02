{ common, pkgs, modules, lib, ... }: {
  imports = [
    modules.jovian
    modules.steam-compat

    common.fonts
    common.nix-build
    common.nix-config
    common.openssh
    common.user
    common.vscode-server
    common.wifi
    common.zsh

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

  programs.steam = {
    enable = true; 
    extraCompatPackages = [
      pkgs.proton-ge
    ];
  };

  system.stateVersion = "23.11";
  hardware.steam-hardware.enable = true;
  services.joycond.enable = true;
  # boot.blacklistedKernelModules = [ "hid-nintendo" ];
}
