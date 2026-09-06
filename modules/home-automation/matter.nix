{ arc, nixosAspectTest, ... }:
{
  arc.home-automation.includes = [ arc.home-automation._.matter ];

  arc.home-automation._.matter.nixos =
    { pkgs, ... }:
    {
      virtualisation.podman.enable = true;
      virtualisation.oci-containers = {
        backend = "podman";
        containers.matterjs-server = {
          image = "ghcr.io/matter-js/matterjs-server:1.4.0@sha256:54232d0d3e7dff5a54759469d2753399270412b4c30c55b31750a4595e4cb236";
          volumes = [ "/var/lib/matter-server:/data" ];
          environment = {
            FABRIC_ID = "1";
            LISTEN_ADDRESS = "127.0.0.1";
            PRIMARY_INTERFACE = "end0";
            TZ = "Australia/Perth";
            VENDOR_ID = "4939";
          };
          extraOptions = [ "--network=host" ];
        };
      };

      # The official image runs as UID/GID 1000. Follow the persisted-state symlink so
      # files created by the previous NixOS Python Matter Server are writable for migration.
      systemd.services.podman-matterjs-server.serviceConfig.ExecStartPre = [
        "+${pkgs.coreutils}/bin/chown -R -H 1000:1000 /var/lib/matter-server"
      ];

      services.tailscale-serve.matter.target = "127.0.0.1:5580";
      networking.firewall.allowedUDPPorts = [ 5540 ];
      # fd36:da06:8db4 is my thread network, battery powered devices exceed the conntrack timeout
      networking.firewall.extraCommands = ''
        ip6tables -I nixos-fw 3 -i end0 -p udp -s fd36:da06:8db4:0::/64 -j nixos-fw-accept
      '';
    };

  flake.tests.matter = nixosAspectTest {
    baseline = [ arc.base ];
    aspects = [ arc.home-automation ];
    expr =
      igloo:
      let
        containers = igloo.virtualisation.oci-containers.containers;
        present = containers ? matterjs-server;
      in
      {
        inherit present;
        details =
          if present then
            let
              container = containers.matterjs-server;
            in
            {
              pythonServerDisabled = !igloo.services.matter-server.enable;
              inherit (container) image volumes;
              fabricId = container.environment.FABRIC_ID;
              listenAddress = container.environment.LISTEN_ADDRESS;
              primaryInterface = container.environment.PRIMARY_INTERFACE;
              vendorId = container.environment.VENDOR_ID;
              hostNetwork = builtins.elem "--network=host" container.extraOptions;
              matterPortOpen = builtins.elem 5540 igloo.networking.firewall.allowedUDPPorts;
              tailscaleTarget = igloo.services.tailscale-serve.matter.target;
            }
          else
            null;
      };
    enabled = {
      present = true;
      details = {
        pythonServerDisabled = true;
        image = "ghcr.io/matter-js/matterjs-server:1.4.0@sha256:54232d0d3e7dff5a54759469d2753399270412b4c30c55b31750a4595e4cb236";
        volumes = [ "/var/lib/matter-server:/data" ];
        fabricId = "1";
        listenAddress = "127.0.0.1";
        primaryInterface = "end0";
        vendorId = "4939";
        hostNetwork = true;
        matterPortOpen = true;
        tailscaleTarget = "127.0.0.1:5580";
      };
    };
    disabled = {
      present = false;
      details = null;
    };
  };
}
