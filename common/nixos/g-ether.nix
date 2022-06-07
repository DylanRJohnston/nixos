{
  hardware.raspberry-pi."4".dwc2.enable = true;

  boot.kernelModules = [
    "dwc2"
    "g_ether"
  ];

  networking.networkmanager.unmanaged = [ "usb0" ];

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
}
