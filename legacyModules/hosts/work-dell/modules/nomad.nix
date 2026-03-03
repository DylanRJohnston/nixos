{
  services.consul = {
    enable = true;
    extraConfig = {
      bootstrap = true;
      server = true;
    };
  };
  services.nomad = {
    enable = true;
    settings = {
      server = {
        enabled = true;
        bootstrap_expect = 1;
      };
      client.enabled = true;
      consul.address = "127.0.0.1:8500";
    };
  };
}
