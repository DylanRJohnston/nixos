{ arc, unitTest, ... }:
{
  arc.home-automation.includes = [
    arc.home-automation._.koreader-sync-server
  ];

  arc.home-automation._.koreader-sync-server.nixos = {
    virtualisation.podman.enable = true;
    virtualisation.oci-containers = {
      backend = "podman";
      containers.koreader-sync-server = {
        image = "koreader/kosync:latest";
        ports = [ "127.0.0.1:17200:17200" ];
        volumes = [
          "/var/lib/koreader-sync-server/logs/app:/app/koreader-sync-server/logs"
          "/var/lib/koreader-sync-server/logs/redis:/var/log/redis"
          "/var/lib/koreader-sync-server/data/redis:/var/lib/redis"
        ];
        environment.ENABLE_USER_REGISTRATION = "true";
      };
    };

    services.tailscale-serve.kosync.target = "127.0.0.1:17200";
  };

  flake.tests.koreader-sync-server = {
    test-enabled = unitTest (
      { arc, igloo, ... }:
      {
        den.hosts.x86_64-linux.igloo.aspects = [
          arc.base
          arc.home-automation
        ];

        expr = {
          inherit (igloo.virtualisation.oci-containers.containers.koreader-sync-server)
            image
            ports
            volumes
            ;
          registration =
            igloo.virtualisation.oci-containers.containers.koreader-sync-server.environment.ENABLE_USER_REGISTRATION;
          tailscaleTarget = igloo.services.tailscale-serve.kosync.target;
        };
        expected = {
          image = "koreader/kosync:latest";
          ports = [ "127.0.0.1:17200:17200" ];
          volumes = [
            "/var/lib/koreader-sync-server/logs/app:/app/koreader-sync-server/logs"
            "/var/lib/koreader-sync-server/logs/redis:/var/log/redis"
            "/var/lib/koreader-sync-server/data/redis:/var/lib/redis"
          ];
          registration = "true";
          tailscaleTarget = "127.0.0.1:17200";
        };
      }
    );

    test-disabled = unitTest (
      { arc, igloo, ... }:
      {
        den.hosts.x86_64-linux.igloo.aspects = [ arc.base ];

        expr = igloo.virtualisation.oci-containers.containers ? koreader-sync-server;
        expected = false;
      }
    );
  };
}
