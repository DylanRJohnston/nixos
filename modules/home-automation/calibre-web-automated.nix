{
  arc,
  den,
  lib,
  nixosAspectTest,
  unitTest,
  ...
}:
{
  arc.home-automation.includes = [
    arc.home-automation._.calibre-web-automated
  ];

  arc.home-automation._.calibre-web-automated = den.lib.perHost (
    { host }:
    {
      nixos =
        { pkgs, ... }:
        {
          assertions = [
            {
              assertion = host.bulkStoragePath != null;
              message = "arc.home-automation._.calibre-web-automated requires host.bulkStoragePath to be defined";
            }
          ];

          virtualisation.podman.enable = true;
          systemd.tmpfiles.rules = [
            "d /var/lib/calibre-web-automated/config 0755 1000 1000 -"
            "d ${host.bulkStoragePath}/calibre-web-automated/ingest 0755 1000 1000 -"
            "d ${host.bulkStoragePath}/calibre-web-automated/library 0755 1000 1000 -"
          ];
          systemd.services.podman-calibre-web-automated = {
            unitConfig.RequiresMountsFor = host.bulkStoragePath;
            # Boot-time tmpfiles may run before removable bulk storage is mounted.
            serviceConfig.ExecStartPre = [
              "${pkgs.systemd}/bin/systemd-tmpfiles --create --prefix=${host.bulkStoragePath}/calibre-web-automated"
            ];
          };

          virtualisation.oci-containers = {
            backend = "podman";
            containers.calibre-web-automated = {
              image = "docker.io/crocodilestick/calibre-web-automated:v4.0.6@sha256:c31a738b6d5ec6982c050063dd3f063b6943eb1051fc81144789f840d9093a8d";
              ports = [ "127.0.0.1:8083:8083" ];
              volumes = [
                "/var/lib/calibre-web-automated/config:/config"
                "${host.bulkStoragePath}/calibre-web-automated/ingest:/cwa-book-ingest"
                "${host.bulkStoragePath}/calibre-web-automated/library:/calibre-library"
              ];
              environment = {
                PUID = "1000";
                PGID = "1000";
                TZ = "Australia/Perth";
              };
            };
          };

          services.tailscale-serve.books.target = "127.0.0.1:8083";
        };
    }
  );

  flake.tests.calibre-web-automated =
    (nixosAspectTest {
      baseline = [ arc.base ];
      aspects = [ arc.home-automation ];
      host.bulkStoragePath = "/srv/bulk";
      expr =
        igloo:
        let
          container = igloo.virtualisation.oci-containers.containers.calibre-web-automated;
        in
        {
          inherit (container)
            image
            ports
            volumes
            environment
            ;
          tailscaleTarget = igloo.services.tailscale-serve.books.target;
          directories = lib.filter (
            rule: lib.hasInfix "calibre-web-automated/" rule
          ) igloo.systemd.tmpfiles.rules;
          requiresMountsFor =
            igloo.systemd.services.podman-calibre-web-automated.unitConfig.RequiresMountsFor;
          createsDirectoriesBeforeStart = lib.any (
            command:
            lib.hasSuffix "bin/systemd-tmpfiles --create --prefix=/srv/bulk/calibre-web-automated" command
          ) igloo.systemd.services.podman-calibre-web-automated.serviceConfig.ExecStartPre;
          portOpen = builtins.elem 8083 igloo.networking.firewall.allowedTCPPorts;
        };
      enabled = {
        image = "docker.io/crocodilestick/calibre-web-automated:v4.0.6@sha256:c31a738b6d5ec6982c050063dd3f063b6943eb1051fc81144789f840d9093a8d";
        ports = [ "127.0.0.1:8083:8083" ];
        volumes = [
          "/var/lib/calibre-web-automated/config:/config"
          "/srv/bulk/calibre-web-automated/ingest:/cwa-book-ingest"
          "/srv/bulk/calibre-web-automated/library:/calibre-library"
        ];
        environment = {
          PUID = "1000";
          PGID = "1000";
          TZ = "Australia/Perth";
        };
        tailscaleTarget = "127.0.0.1:8083";
        directories = [
          "d /var/lib/calibre-web-automated/config 0755 1000 1000 -"
          "d /srv/bulk/calibre-web-automated/ingest 0755 1000 1000 -"
          "d /srv/bulk/calibre-web-automated/library 0755 1000 1000 -"
        ];
        requiresMountsFor = "/srv/bulk";
        createsDirectoriesBeforeStart = true;
        portOpen = false;
      };
      disabledErr.msg = "attribute.*calibre-web-automated.*missing";
    })
    // {
      test-requires-storage = unitTest (
        {
          arc,
          igloo,
          lib,
          ...
        }:
        let
          message = "arc.home-automation._.calibre-web-automated requires host.bulkStoragePath to be defined";
        in
        {
          den.hosts.x86_64-linux.igloo = {
            users.tux = { };
            aspects = [
              arc.base
              arc.home-automation
            ];
          };

          expr = lib.findFirst (assertion: assertion.message == message) null igloo.assertions;
          expected = {
            assertion = false;
            inherit message;
          };
        }
      );
    };
}
