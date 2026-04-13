{
  arc,
  lib,
  unitTest,
  ...
}:
{
  arc.mesh.includes = [ arc.mesh._.services ];

  arc.mesh._.services.nixos =
    { pkgs, config, ... }:
    let
      cfg = config.services.tailscale-serve;

      script =
        cfg
        |> lib.mapAttrsToList (
          name:
          { protocol, target }:
          "${lib.getExe pkgs.tailscale} serve --service=svc:${name} --${protocol}=443 ${target} || true"
        )
        |> lib.concatLines;
    in
    {
      options.services.tailscale-serve = lib.mkOption {
        type = lib.types.lazyAttrsOf (
          lib.types.submodule {
            options.protocol = lib.mkOption {
              type = lib.types.enum [ "https" ];
              default = "https";
            };

            options.target = lib.mkOption {
              type = lib.types.str;
            };
          }
        );
      };

      config.systemd.services.tailscale-serve = {
        after = [
          "tailscaled.service"
          "tailscaled-autoconnect.service"
        ];
        wants = [
          "tailscaled.service"
        ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
        };

        inherit script;
      };
    };

  flake.tests.mesh.test-service = unitTest (
    { arc, igloo, ... }:
    {
      den.hosts.x86_64-linux.igloo.aspects = [
        arc.base
        arc.mesh._.services
      ];

      den.aspects.igloo.nixos.services.tailscale-serve = {
        hass.target = "localhost:8123";
        bass.target = "localhost:8124";
      };

      expr =
        igloo.systemd.services.tailscale-serve.script
        |> lib.strings.split "\n"
        |> lib.filter (x: lib.typeOf x == "string" && x != "")
        |> lib.map (lib.strings.substring 65 (-1));
      expected = [
        "tailscale serve --service=svc:bass --https=443 localhost:8124 || true"
        "tailscale serve --service=svc:hass --https=443 localhost:8123 || true"
      ];
    }
  );

}
