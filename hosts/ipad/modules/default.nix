{ common
, config
, hardware
, modulesPath
, pkgs
, ...
}: {

  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    common.nix-config
    hardware.nixosModules.raspberry-pi-4
    common.user
    common.fonts
    common.xserver
    common.console
  ];

  # Issue https://github.com/NixOS/nixpkgs/issues/126755#issuecomment-869149243
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
      })
    (self: super: {
      alacritty = super.alacritty.overrideAttrs (_: {
        src = super.fetchFromGitHub {
          owner = "alacritty";
          repo = "alacritty";
          rev = "9f8c5c4f5659308ee1bb3a22e7d0ca2d04db8874";
          sha256 = "";
        };
      });
    })
  ];

  boot.loader.raspberryPi.firmwareConfig = "dtoverlay=dwc2";

  boot.kernelModules = [
    "dwc2"
    "g_ether"
  ];

  hardware.raspberry-pi."4" = {
    dwc2.enable = true;
    fkms-3d.enable = true;
  };

  programs.zsh.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";
  networking.networkmanager.enable = true;
  
 }
