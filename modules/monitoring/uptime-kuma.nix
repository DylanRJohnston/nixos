{ arc, unitTest, ... }:
{
  arc.monitoring.includes = [ arc.monitoring._.uptime-kuma ];

  arc.monitoring._.uptime-kuma.nixos = {
    virtualisation.podman.enable = true;
    virtualisation.oci-containers = {
      backend = "podman";
      containers.uptime-kuma = {
        image = "docker.io/louislam/uptime-kuma:2.5.3@sha256:3e24e96c89efff0e3a4b0698cbdd36c15ad3022371db57166e5588853002ee5c";
        ports = [ "127.0.0.1:3001:3001" ];
        volumes = [ "/var/lib/uptime-kuma:/app/data" ];
      };
    };

    services.tailscale-serve.uptime.target = "127.0.0.1:3001";
  };

  flake.tests.uptime-kuma = {
    test-enabled = unitTest (
      { arc, igloo, ... }:
      {
        den.hosts.x86_64-linux.igloo.aspects = [
          arc.base
          arc.monitoring
        ];

        expr = {
          inherit (igloo.virtualisation.oci-containers.containers.uptime-kuma)
            image
            ports
            volumes
            ;
          podmanEnabled = igloo.virtualisation.podman.enable;
          tailscaleTarget = igloo.services.tailscale-serve.uptime.target;
          portOpen = builtins.elem 3001 igloo.networking.firewall.allowedTCPPorts;
        };
        expected = {
          image = "docker.io/louislam/uptime-kuma:2.5.3@sha256:3e24e96c89efff0e3a4b0698cbdd36c15ad3022371db57166e5588853002ee5c";
          ports = [ "127.0.0.1:3001:3001" ];
          volumes = [ "/var/lib/uptime-kuma:/app/data" ];
          podmanEnabled = true;
          tailscaleTarget = "127.0.0.1:3001";
          portOpen = false;
        };
      }
    );

    test-disabled = unitTest (
      { arc, igloo, ... }:
      {
        den.hosts.x86_64-linux.igloo.aspects = [ arc.base ];

        expr = {
          container = igloo.virtualisation.oci-containers.containers ? uptime-kuma;
          tailscaleService = igloo.services.tailscale-serve ? uptime;
        };
        expected = {
          container = false;
          tailscaleService = false;
        };
      }
    );
  };
}
