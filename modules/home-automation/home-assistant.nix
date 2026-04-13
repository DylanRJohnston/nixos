{ arc, ... }:
{
  arc.home-automation.includes = [
    arc.home-automation._.home-assistant
    arc.home-automation._.home-assistant._.mesh
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

      config = {
        default_config = { };
        http = {
          use_x_forwarded_for = true;
          trusted_proxies = [ "127.0.0.1" ];
        };
      };
    };

    # Required for homekit component
    networking.firewall.allowedTCPPorts = [ 21064 ];
  };

  arc.home-automation._.home-assistant._.mesh.nixos = { pkgs, lib, ... }: {
    systemd.services.tailscaled-home-assistant = {
      after = [
        "tailscaled.service"
        "tailscaled-autoconnect.service"
        "home-assistant.service"
      ];
      wants = [ "tailscaled.service" "home-assistant.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
      };
      script = ''
        ${lib.getExe pkgs.tailscale} serve --service=svc:hass --https=443 127.0.0.1:8123 || true
      '';
    };
  };
}
