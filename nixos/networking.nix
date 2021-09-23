{
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = true;
    servers = builtins.fromJSON (builtins.readFile ./servers.json);
  };

  networking = {
    useDHCP = false;
    networkmanager = {
      enable = true;
      # extraConfig = ''
      #   [connection-wifi-spaarc]

      # '';
    };

    # interfaces.enp8s0u2u4.useDHCP = false;
    # interfaces.enp8s0u2u4.ipv4.routes = [{
    #   address = "172.23.0.0";
    #   prefixLength = 16;
    #   via = "172.23.18.254";
    # }];
  };
}
