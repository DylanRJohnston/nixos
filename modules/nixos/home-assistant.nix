{
  flake.modules.nixos.home-automation = {
    services.home-assistant = {
      enable = true;
      openFirewall = true;
      extraComponents = [
        "default_config"
        "met"
        "esphome"
        "homekit"
      ];

      config.default_config = { };
    };

    # Required for homekit component
    networking.firewall.allowedTCPPorts = [ 21064 ];
  };
}
