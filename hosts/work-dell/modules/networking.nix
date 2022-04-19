{
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
