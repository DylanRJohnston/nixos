{ arc, ... }:
{
  arc.home-automation.includes = [ arc.home-automation._.matter ];

  arc.home-automation._.matter.nixos = { pkgs, ... }: {
    services.matter-server = {
      enable = true;
    };

    systemd.services.matter-server = {
      environment.SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

      serviceConfig.BindReadOnlyPaths = [
        "/etc/resolv.conf"
        "/etc/hosts"
        "/etc/nsswitch.conf"
        "/etc/ssl/certs"
      ];
    };

    services.tailscale-serve."matter".target = "127.0.0.1:5580";
  };
}
