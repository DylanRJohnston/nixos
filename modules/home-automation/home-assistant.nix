{ arc, ... }:
{
  arc.home-automation.includes = [
    arc.home-automation._.home-assistant
  ];

  arc.home-automation._.home-assistant.nixos =
    { pkgs, ... }:
    {
      services.home-assistant = {
        enable = true;
        openFirewall = true;
        extraComponents = [
          "default_config"
          "esphome"
          "homekit"
          "matter"
          "met"
          "otbr"
          "thread"
          "zha"
        ];

        extraPackages =
          python3Packages: with python3Packages; [
            afsapi
            aiohomekit
            aiohue
            aiopyarr
            androidtvremote2
            b2sdk
            getmac
            gtts
            ibeacon-ble
            influxdb
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

      # services.openthread-border-router = {
      #   enable = true;
      #   openFirewall = true;
      #   backboneInterfaces = [ "end0" ];
      #   web.enable = true;
      #   radio = {
      #     device = "/dev/serial/by-id/usb-SMLIGHT_SMLIGHT_SLZB-07_c6bcdaf5dad5ef11977a694b49d2c684-if00-port0";
      #     baudRate = 460800;
      #     flowControl = true;
      #   };
      # };

      # systemd.services.otbr-agent = {
      #   serviceConfig = {
      #     ExecStartPost = [
      #       "${pkgs.bash}/bin/bash -c 'for i in {1..10}; do [ -S /var/run/openthread-wpan0.sock ] && break; sleep 1; done'"
      #       "+${pkgs.coreutils}/bin/chown root:otbr-web /var/run/openthread-wpan0.sock"
      #       "+${pkgs.coreutils}/bin/chmod 660 /var/run/openthread-wpan0.sock"
      #     ];
      #   };
      # };

      # services.tailscale-serve."otbr".target = "127.0.0.1:8082";
      # services.tailscale-serve."otbr-api".target = "127.0.0.1:8081";
    };
}
