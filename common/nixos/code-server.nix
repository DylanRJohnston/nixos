{
  services.code-server = {
    enable = true;
    host = "10.55.0.1";
    auth = "none";
  };

  networking.firewall.allowedTCPPorts = [ 4444 ];
}
