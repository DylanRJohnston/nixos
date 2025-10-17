{ common, ... }:
{
  imports = [
    common.base
    common.nix-daemon
  ];

  # nix.settings.substituters = [ "http://cache.nixos.org" ];
  nix.settings = {
    ssl-cert-file = "/Users/dylan.johnston/.certs/certs.crt";
    trusted-users = [
      "root"
      "dylan.johnston"
    ];
  };
  launchd.daemons.nix-daemon.environment = {
    NIX_SSL_CERT_FILE = "/Users/dylan.johnston/.certs/certs.crt";
    http_proxy = "http://localhost:3128";
    https_proxy = "http://localhost:3128";
    all_proxy = "http://localhost:3128";
    no_proxy = "localhost,127.0.0.1,.github.com";
  };
}
