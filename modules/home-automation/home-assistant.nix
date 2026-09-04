{ arc, unitTest, ... }:
{
  arc.home-automation.includes = [
    arc.home-automation._.home-assistant
  ];

  arc.home-automation._.home-assistant = {
    nixos =
      { ... }:
      {
        virtualisation.podman.enable = true;
        virtualisation.oci-containers = {
          backend = "podman";
          containers.homeassistant = {
            image = "ghcr.io/home-assistant/home-assistant:2026.9.0@sha256:372d991e58882a1d8c68c07e9aa3f3b509276e695355f73ccdb03baa70407293";
            volumes = [ "/etc/nixos/modules/home-automation/config:/config" ];
            environment.TZ = "Australia/Perth";
            extraOptions = [
              "--network=host"
              # Podman filters Tailscale's resolver from the generated resolv.conf.
              "--dns=100.100.100.100"
              # Required by Home Assistant's Bluetooth and DHCP watchers.
              "--cap-add=NET_ADMIN"
              "--cap-add=NET_RAW"
              # "--device=/dev/ttyACM0:/dev/ttyACM0"
              "--device=/dev/serial/by-id/usb-SMLIGHT_SMLIGHT_SLZB-07_c6bcdaf5dad5ef11977a694b49d2c684-if00-port0:/dev/serial/by-id/usb-SMLIGHT_SMLIGHT_SLZB-07_c6bcdaf5dad5ef11977a694b49d2c684-if00-port0"
            ];
          };
        };

        networking.firewall.allowedTCPPorts = [
          8123
          # Required for HomeKit component.
          21064
        ];

        # AirPlay receivers connect back to Home Assistant on dynamic UDP ports.
        networking.firewall.extraCommands = ''
          iptables -I nixos-fw 1 -p udp -s 192.168.0.129 -j nixos-fw-accept
          iptables -I nixos-fw 1 -p udp -s 192.168.0.50 -j nixos-fw-accept
        '';

        # Expose Home Assistant as a Tailscale Service.
        services.tailscale-serve."hass".target = "127.0.0.1:8123";

        services.avahi = {
          enable = true;
          nssmdns4 = true;
          nssmdns6 = true;
          openFirewall = true;
        };

        services.dbus.enable = true;
      };
  };

  flake.tests.home-assistant = {
    test-enabled = unitTest (
      { arc, igloo, ... }:
      {
        den.hosts.x86_64-linux.igloo.aspects = [
          arc.base
          arc.home-automation
        ];

        expr =
          let
            container = igloo.virtualisation.oci-containers.containers.homeassistant;
          in
          {
            inherit (container) image;
            tailscaleDns = builtins.elem "--dns=100.100.100.100" container.extraOptions;
          };
        expected = {
          image = "ghcr.io/home-assistant/home-assistant:2026.9.0@sha256:372d991e58882a1d8c68c07e9aa3f3b509276e695355f73ccdb03baa70407293";
          tailscaleDns = true;
        };
      }
    );

    test-disabled = unitTest (
      { arc, igloo, ... }:
      {
        den.hosts.x86_64-linux.igloo.aspects = [ arc.base ];

        expr = igloo.virtualisation.oci-containers.containers ? homeassistant;
        expected = false;
      }
    );
  };
}
