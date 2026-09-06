{ arc, nixosAspectTest, ... }:
{
  arc.monitoring.includes = [ arc.monitoring._.uptime-kuma ];

  arc.monitoring._.uptime-kuma.nixos = {
    virtualisation.podman.enable = true;
    systemd.services.podman-uptime-kuma.serviceConfig.StateDirectory = "uptime-kuma";

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

  flake.tests.uptime-kuma = nixosAspectTest {
    baseline = [ arc.base ];
    aspects = [ arc.monitoring ];
    expr =
      igloo:
      let
        container = igloo.virtualisation.oci-containers.containers ? uptime-kuma;
        tailscaleService = igloo.services.tailscale-serve ? uptime;
      in
      {
        inherit container tailscaleService;
      }
      // (
        if container then
          {
            inherit (igloo.virtualisation.oci-containers.containers.uptime-kuma)
              image
              ports
              volumes
              ;
            podmanEnabled = igloo.virtualisation.podman.enable;
            stateDirectory = igloo.systemd.services.podman-uptime-kuma.serviceConfig.StateDirectory;
            portOpen = builtins.elem 3001 igloo.networking.firewall.allowedTCPPorts;
          }
        else
          { }
      )
      // (
        if tailscaleService then
          {
            tailscaleTarget = igloo.services.tailscale-serve.uptime.target;
          }
        else
          { }
      );
    enabled = {
      container = true;
      tailscaleService = true;
      image = "docker.io/louislam/uptime-kuma:2.5.3@sha256:3e24e96c89efff0e3a4b0698cbdd36c15ad3022371db57166e5588853002ee5c";
      ports = [ "127.0.0.1:3001:3001" ];
      volumes = [ "/var/lib/uptime-kuma:/app/data" ];
      podmanEnabled = true;
      stateDirectory = "uptime-kuma";
      tailscaleTarget = "127.0.0.1:3001";
      portOpen = false;
    };
    disabled = {
      container = false;
      tailscaleService = false;
    };
  };
}
