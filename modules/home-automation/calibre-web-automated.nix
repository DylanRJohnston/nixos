{
  arc,
  den,
  lib,
  nixosAspectTest,
  unitTest,
  ...
}:
let
  cwaLoansScript = ./calibre-web-automated-loans.py;
in
{
  arc.home-automation.includes = [
    arc.home-automation._.calibre-web-automated
  ];

  arc.home-automation._.calibre-web-automated = den.lib.perHost (
    { host }:
    {
      nixos =
        { pkgs, ... }:
        let
          cwaLoans = pkgs.writeShellApplication {
            name = "cwa-loans";
            runtimeInputs = [ pkgs.podman ];
            text = ''
              if (( EUID != 0 )); then
                echo "cwa-loans must run as root; try: sudo cwa-loans $*" >&2
                exit 1
              fi

              exec podman exec \
                --user 1000:1000 \
                --env CALIBRE_CONFIG_DIRECTORY=/config/.config/calibre \
                calibre-web-automated \
                /app/calibre/calibre-debug \
                /opt/cwa-loans.py \
                "$@"
            '';
          };
        in
        {
          assertions = [
            {
              assertion = host.bulkStoragePath != null;
              message = "arc.home-automation._.calibre-web-automated requires host.bulkStoragePath to be defined";
            }
          ];

          virtualisation.podman.enable = true;
          environment.systemPackages = [ cwaLoans ];
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
              image = "ghcr.io/new-usemame/calibre-web-nextgen:v4.1.43@sha256:092b583be20202a983797d27b75960ece9625517fa6916068574e23ef4e092b1";
              ports = [ "127.0.0.1:8083:8083" ];
              volumes = [
                "/var/lib/calibre-web-automated/config:/config"
                "${host.bulkStoragePath}/calibre-web-automated/ingest:/cwa-book-ingest"
                "${host.bulkStoragePath}/calibre-web-automated/library:/calibre-library"
                "${cwaLoansScript}:/opt/cwa-loans.py:ro"
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
          loansCommandInstalled = lib.any (
            package: lib.getName package == "cwa-loans"
          ) igloo.environment.systemPackages;
          portOpen = builtins.elem 8083 igloo.networking.firewall.allowedTCPPorts;
        };
      enabled = {
        image = "ghcr.io/new-usemame/calibre-web-nextgen:v4.1.43@sha256:092b583be20202a983797d27b75960ece9625517fa6916068574e23ef4e092b1";
        ports = [ "127.0.0.1:8083:8083" ];
        volumes = [
          "/var/lib/calibre-web-automated/config:/config"
          "/srv/bulk/calibre-web-automated/ingest:/cwa-book-ingest"
          "/srv/bulk/calibre-web-automated/library:/calibre-library"
          "${cwaLoansScript}:/opt/cwa-loans.py:ro"
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
        loansCommandInstalled = true;
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
