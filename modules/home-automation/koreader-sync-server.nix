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
        image = "koreader/kosync:v2.1.1@sha256:bb3f13615365703315a43b9059f65e71e876440f867e23a42bf27f2fa18264e1";
        ports = [ "127.0.0.1:7200:7200" ];
        volumes = [
          "/var/lib/koreader-sync-server/logs/app:/app/koreader-sync-server/logs"
          "/var/lib/koreader-sync-server/logs/redis:/var/log/redis"
          "/var/lib/koreader-sync-server/data/redis:/var/lib/redis"
        ];
        environment.ENABLE_USER_REGISTRATION = "true";
      };
    };

    services.tailscale-serve.kosync.target = "https+insecure://127.0.0.1:7200";
  };

  flake.tests.koreader-sync-server = {
    test-enabled = unitTest (
      { arc, igloo, lib, ... }:
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
          directories = lib.filter (
            lib.hasPrefix "d /var/lib/koreader-sync-server/"
          ) igloo.systemd.tmpfiles.rules;
          portOpen = builtins.elem 7200 igloo.networking.firewall.allowedTCPPorts;
        };
        expected = {
          image = "koreader/kosync:v2.1.1@sha256:bb3f13615365703315a43b9059f65e71e876440f867e23a42bf27f2fa18264e1";
          ports = [ "127.0.0.1:7200:7200" ];
          volumes = [
            "/var/lib/koreader-sync-server/logs/app:/app/koreader-sync-server/logs"
            "/var/lib/koreader-sync-server/logs/redis:/var/log/redis"
            "/var/lib/koreader-sync-server/data/redis:/var/lib/redis"
          ];
          registration = "true";
          tailscaleTarget = "https+insecure://127.0.0.1:7200";
          directories = [
            "d /var/lib/koreader-sync-server/logs/app 0755 root root -"
            "d /var/lib/koreader-sync-server/logs/redis 0755 root root -"
            "d /var/lib/koreader-sync-server/data/redis 0755 root root -"
          ];
          portOpen = false;
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
