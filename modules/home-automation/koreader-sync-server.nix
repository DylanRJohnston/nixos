{ arc, unitTest, ... }:
{
  arc.home-automation.includes = [
    arc.home-automation._.koreader-sync-server
  ];

  arc.home-automation._.koreader-sync-server.nixos = {
    virtualisation.podman.enable = true;
    systemd.tmpfiles.rules = [
      "d /var/lib/koreader-sync-server/logs/app 0755 root root -"
      "d /var/lib/koreader-sync-server/logs/redis 0755 root root -"
      "d /var/lib/koreader-sync-server/data/redis 0755 root root -"
    ];

    virtualisation.oci-containers = {
      backend = "podman";
      containers.koreader-sync-server = {
        image = "koreader/kosync:latest";
        ports = [ "0.0.0.0:7200:7200" ];
        volumes = [
          "/var/lib/koreader-sync-server/logs/app:/app/koreader-sync-server/logs"
          "/var/lib/koreader-sync-server/logs/redis:/var/log/redis"
          "/var/lib/koreader-sync-server/data/redis:/var/lib/redis"
        ];
        environment.ENABLE_USER_REGISTRATION = "true";
      };
    };

    services.tailscale-serve.kosync.target = "127.0.0.1:7200";
    networking.firewall.allowedTCPPorts = [ 7200 ];
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
          directories = igloo.systemd.tmpfiles.rules;
        };
        expected = {
          image = "koreader/kosync:latest";
          ports = [ "127.0.0.1:7200:7200" ];
          volumes = [
            "/var/lib/koreader-sync-server/logs/app:/app/koreader-sync-server/logs"
            "/var/lib/koreader-sync-server/logs/redis:/var/log/redis"
            "/var/lib/koreader-sync-server/data/redis:/var/lib/redis"
          ];
          registration = "true";
          tailscaleTarget = "127.0.0.1:7200";
          directories = [
            "d /var/lib/koreader-sync-server/logs/app 0755 root root -"
            "d /var/lib/koreader-sync-server/logs/redis 0755 root root -"
            "d /var/lib/koreader-sync-server/data/redis 0755 root root -"
          ];
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
