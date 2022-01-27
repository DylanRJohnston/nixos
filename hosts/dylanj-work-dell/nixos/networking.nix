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
    hostName = "dylanj-work-dell";

    useDHCP = false;
    networkmanager = {
      enable = true;
      extraConfig = ''
        [device-mac-randomization]
        wifi.scan-rand-mac-address=no
      '';
    };
  };
}
