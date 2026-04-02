{
  arc.home-automation.nixos = {
    services.home-assistant = {
      enable = true;
      openFirewall = true;
      extraComponents = [
        "default_config"
        "met"
        "esphome"
        "homekit"
      ];

      extraPackages =
        python3Packages: with python3Packages; [
          aiohomekit
          aiohue
          androidtvremote2
          getmac
          gtts
          ibeacon-ble
          pyatv
          pychromecast
          python-otbr-api
          samsungctl
          samsungtvws
          yalexs-ble
        ];

      config.default_config = { };
    };

    # Required for homekit component
    networking.firewall.allowedTCPPorts = [ 21064 ];
  };
}
