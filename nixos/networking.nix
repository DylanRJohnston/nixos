{
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = true;
    servers = [
      "/.fugro/172.23.18.10"
      "8.8.8.8"
      "8.8.4.4"
    ];
  };

  networking = {
    useDHCP = false;
    networkmanager = {
      enable = true;
      extraConfig = ''
        [connection-wifi-spaarc]
        match-device=interface-name:wlo1
        ipv4.route-metric=99

        [connection-ethernet-spaarc]
        match-device=interface-name:enp8s0u2u4
        route1=172.23.0.0/16,172.23.18.254
      '';
    };

    # interfaces.enp8s0u2u4.useDHCP = false;
    # interfaces.enp8s0u2u4.ipv4.routes = [{
    #   address = "172.23.0.0";
    #   prefixLength = 16;
    #   via = "172.23.18.254";
    # }];
  };
}
