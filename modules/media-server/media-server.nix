{
  arc.media-server = {
    user.extraGroups = [ "docker" ];

    nixos =
      { pkgs, ... }:
      {
        virtualisation.docker.enable = true;

        networking.firewall.allowedTCPPorts = [
          5055
          6767
          7878
          8080
          8096
          8989
          9080
          9696
          8191
        ];

        networking.firewall.allowedUDPPorts = [ 1900 ];

        services.tailscale-serve = {
          bazarr.target = "127.0.0.1:6767";
          jellyfin.target = "127.0.0.1:8096";
          jellyseerr.target = "127.0.0.1:5055";
          prowlarr.target = "127.0.0.1:9696";
          qbittorrent.target = "127.0.0.1:8080";
          radarr.target = "127.0.0.1:7878";
          sabnzbd.target = "127.0.0.1:9080";
          sonarr.target = "127.0.0.1:8989";
        };

        systemd.tmpfiles.rules = [
          "L+ /mnt/external/docker-compose.yaml - - - - /etc/nixos/modules/media-server/docker-compose.yaml"
        ];

        # Ensure the symlinked compose file exists before service start
        systemd.services.media-server-compose = {
          description = "Media Server Docker Compose Stack";
          after = [
            "network-online.target"
            "docker.service"
            "systemd-tmpfiles-setup.service"
          ];
          wants = [
            "network-online.target"
            "docker.service"
          ];
          requires = [ "docker.service" ];
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            WorkingDirectory = "/mnt/external";
            ExecStart = "${pkgs.docker}/bin/docker compose -f /mnt/external/docker-compose.yaml up -d";
            ExecStop = "${pkgs.docker}/bin/docker compose -f /mnt/external/docker-compose.yaml down";
            TimeoutStartSec = 0;
            TimeoutStopSec = 120;
          };
        };
      };
  };
}
