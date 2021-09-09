{
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = true;
    servers = builtins.fromJSON (builtins.readFile ./servers.json);
  };

  networking = {
    networkmanager = {
      enable = true;
    };

    useDHCP = false;
    interfaces = {
      eno2.useDHCP = true;
      enp8s0u2u4 = {
        useDHCP = true;
        ipv4.routes = [{
          address = "172.23.0.0";
          prefixLength = 16;
          via = "172.23.18.254";
        }];
      };
      wlo1.useDHCP = true;
    };

    dhcpcd.extraConfig = ''
      ssid spaarc
      metric 99
    '';
  };
}
