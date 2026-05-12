{ arc, ... }:
{
  arc.home-automation.includes = [
    arc.home-automation._.home-assistant
  ];

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
          aiopyarr
          androidtvremote2
          b2sdk
          getmac
          gtts
          ibeacon-ble
          isal
          jellyfin-apiclient-python
          pyatv
          pychromecast
          pysmlight
          python-otbr-api
          qbittorrent-api
          samsungctl
          samsungtvws
          yalexs-ble
          zha
          zlib-ng
        ];

      config = {
        default_config = { };
        http = {
          use_x_forwarded_for = true;
          trusted_proxies = [ "127.0.0.1" ];
        };
        automation = "!include automations.yaml";
        script = "!include scripts.yaml";
        scene = "!include scenes.yaml";
        zha.zigpy_config.ota.extra_providers = [ { type = "ikea"; } ];
      };
    };

    # Required for homekit component
    networking.firewall.allowedTCPPorts = [ 21064 ];

    # Expose Home Assistant as a Tailscale Service
    services.tailscale-serve."hass".target = "127.0.0.1:8123";

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
      openFirewall = true;
    };

    services.dbus.enable = true;
  };
}
