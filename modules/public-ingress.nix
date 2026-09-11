{
  arc,
  den,
  inputs,
  unitTest,
  ...
}:
{
  arc.public-ingress = den.lib.perHost (
    { host }:
    let
      secretFile = "${inputs.self}/secrets/${host.name}/cloudflare-tunnel.yaml";
    in
    {
      includes = [ arc.secrets ];

      nixos =
        { config, ... }:
        {
          assertions = [
            {
              assertion = builtins.pathExists secretFile;
              message = "arc.public-ingress requires secrets/${host.name}/cloudflare-tunnel.yaml to exist";
            }
          ];

          sops.secrets.cloudflare-tunnel-token = {
            sopsFile = secretFile;
            key = "key";
            restartUnits = [ "podman-public-ingress.service" ];
          };

          virtualisation.podman.enable = true;
          virtualisation.oci-containers = {
            backend = "podman";
            containers.public-ingress = {
              image = "docker.io/cloudflare/cloudflared:2026.8.2@sha256:0aa26e284f05e6c77ae375b8c9c11d9eb6a448fb7bcd8d40f31cb6176189eb38";
              cmd = [
                "tunnel"
                "--no-autoupdate"
                "run"
                "--token-file"
                "/run/secrets/cloudflare-tunnel-token"
              ];
              volumes = [
                "${config.sops.secrets.cloudflare-tunnel-token.path}:/run/secrets/cloudflare-tunnel-token:ro"
              ];
              extraOptions = [ "--network=host" ];
            };
          };

          systemd.services.podman-public-ingress = {
            after = [ "sops-install-secrets.service" ];
            requires = [ "sops-install-secrets.service" ];
          };
        };
    }
  );

  flake.tests.public-ingress = {
    test-enabled = unitTest (
      {
        arc,
        config,
        lib,
        ...
      }:
      let
        mimir = config.flake.nixosConfigurations.mimir.config;
        container = mimir.virtualisation.oci-containers.containers.public-ingress;
        secret = mimir.sops.secrets.cloudflare-tunnel-token;
        service = mimir.systemd.services.podman-public-ingress;
      in
      {
        den.hosts.x86_64-linux.public-ingress-test = {
          name = "mimir";
          users.tux = { };
          aspects = [
            arc.base
            arc.public-ingress
          ];
        };

        expr = {
          inherit (container)
            cmd
            extraOptions
            image
            volumes
            ;
          podmanEnabled = mimir.virtualisation.podman.enable;
          secret = {
            inherit (secret) key restartUnits;
            expectedSource = lib.hasSuffix "/secrets/mimir/cloudflare-tunnel.yaml" secret.sopsFile;
            sourceExists = builtins.pathExists secret.sopsFile;
          };
          inherit (service) after requires;
        };
        expected = {
          image = "docker.io/cloudflare/cloudflared:2026.8.2@sha256:0aa26e284f05e6c77ae375b8c9c11d9eb6a448fb7bcd8d40f31cb6176189eb38";
          cmd = [
            "tunnel"
            "--no-autoupdate"
            "run"
            "--token-file"
            "/run/secrets/cloudflare-tunnel-token"
          ];
          volumes = [
            "/run/secrets/cloudflare-tunnel-token:/run/secrets/cloudflare-tunnel-token:ro"
          ];
          extraOptions = [ "--network=host" ];
          podmanEnabled = true;
          secret = {
            key = "key";
            restartUnits = [ "podman-public-ingress.service" ];
            expectedSource = true;
            sourceExists = true;
          };
          after = [
            "network-online.target"
            "sops-install-secrets.service"
          ];
          requires = [ "sops-install-secrets.service" ];
        };
      }
    );

    test-disabled = unitTest (
      { arc, igloo, ... }:
      {
        den.hosts.x86_64-linux.igloo = {
          users.tux = { };
          aspects = [ arc.base ];
        };

        expr = igloo.virtualisation.oci-containers.containers ? public-ingress;
        expected = false;
      }
    );

    test-requires-host-secret = unitTest (
      {
        arc,
        igloo,
        lib,
        ...
      }:
      let
        message = "arc.public-ingress requires secrets/igloo/cloudflare-tunnel.yaml to exist";
      in
      {
        den.hosts.x86_64-linux.igloo = {
          users.tux = { };
          aspects = [
            arc.base
            arc.public-ingress
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
