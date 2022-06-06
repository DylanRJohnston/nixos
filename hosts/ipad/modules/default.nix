{ common
, config
, hardware
, lib
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
    # common.xserver
    # common.console
  ];

  # Issue https://github.com/NixOS/nixpkgs/issues/126755#issuecomment-869149243
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
      })
  ];

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
  networking.networkmanager.unmanaged = [ "usb0" ];

  fileSystems = {
    "/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
      options = lib.mkForce [ "nofail" ];
    };
  };

  services.openssh.enable = true;
  
  services.dhcpd4 = {
    enable = true;
    interfaces = [ "usb0" ];
    extraConfig = ''
      option subnet-mask 255.255.255.0;
      option broadcast-address 10.55.0.255;
      subnet 10.55.0.0 netmask 255.255.255.0 {
        range 10.55.0.2 10.55.0.254;
      }
    '';
  };

  networking.interfaces.usb0 = {
    ipv4.addresses = [{
      address = "10.55.0.1";
      prefixLength = 24;
    }];
  };

  programs.mosh.enable = true;

  services.code-server = {
    enable = true;
    host = "10.55.0.1";
    auth = "none";
  };

  networking.firewall.allowedTCPPorts = [ 4444 ];
}
