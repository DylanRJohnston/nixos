{ arc, unitTest, ... }:
{
  arc.home-automation.includes = [
    arc.home-automation._.music-assistant
  ];

  arc.home-automation._.music-assistant.nixos = {
    virtualisation.podman.enable = true;
    virtualisation.oci-containers = {
      backend = "podman";
      containers.music-assistant = {
        image = "ghcr.io/music-assistant/server:latest";
        volumes = [ "/var/lib/music-assistant:/data" ];
        environment = {
          LOG_LEVEL = "info";
          TZ = "Australia/Perth";
        };
        extraOptions = [ "--network=host" ];
      };
    };

    networking.firewall.allowedTCPPorts = [
      8095
      8097
    ];

    services.tailscale-serve.music.target = "127.0.0.1:8095";
  };

  flake.tests.music-assistant = {
    test-enabled = unitTest (
      { arc, igloo, ... }:
      {
        den.hosts.x86_64-linux.igloo.aspects = [
          arc.base
          arc.home-automation
        ];

        expr = {
          inherit (igloo.virtualisation.oci-containers.containers.music-assistant) image volumes;
          hostNetwork = builtins.elem "--network=host" igloo.virtualisation.oci-containers.containers.music-assistant.extraOptions;
          openPorts = builtins.all (port: builtins.elem port igloo.networking.firewall.allowedTCPPorts) [
            8095
            8097
          ];
          tailscaleTarget = igloo.services.tailscale-serve.music.target;
        };
        expected = {
          image = "ghcr.io/music-assistant/server:latest";
          volumes = [ "/var/lib/music-assistant:/data" ];
          hostNetwork = true;
          openPorts = true;
          tailscaleTarget = "127.0.0.1:8095";
        };
      }
    );

    test-disabled = unitTest (
      { arc, igloo, ... }:
      {
        den.hosts.x86_64-linux.igloo.aspects = [ arc.base ];

        expr = igloo.virtualisation.oci-containers.containers ? music-assistant;
        expected = false;
      }
    );
  };
}
