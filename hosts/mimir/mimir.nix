{ arc, ... }:
{
  den.hosts.aarch64-linux.mimir = {
    users.dylanj = { };

    aspects = with arc; [
      base
      home-automation
      mesh
      {
        nixos = {
          networking.firewall.interfaces.wlan0.allowedTCPPorts = [
            9080
            8096
            6767
            5055
            9696
            8080
            7878
            8989
          ];

          networking.firewall.interfaces.wlan0.allowedUDPPorts = [ 1900 ];

          virtualisation.docker.enable = true;
        };
      }
    ];
  };
}
