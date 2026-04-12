{ arc, ... }:
{
  arc.home-automation.includes = [ arc.home-automation._.home-assistant ];

  arc.home-automation._.home-assistant.nixos = {
    services.home-assistant = {
      enable = true;
      openFirewall = true;
      extraComponents = [
        "default_config"
        "esphome"
        "homekit"
        "matter"
        "met"
        "thread"
        "zha"
      ];

      extraPackages =
        python3Packages: with python3Packages; [
          aiohomekit
          aiohue
          androidtvremote2
          getmac
          gtts
          ibeacon-ble
          isal
          pyatv
          pychromecast
          python-otbr-api
          samsungctl
          samsungtvws
          yalexs-ble
          zha
          zlib-ng
        ];

      config.default_config = { };
    };

    # Required for homekit component
    networking.firewall.allowedTCPPorts = [ 21064 ];
  };
}
