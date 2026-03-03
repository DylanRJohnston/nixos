{
  lib,
  config,
  ...
}:
{
  options.custom.home-assistant.enable = lib.mkEnableOption "Enable home assistant service";
  config = lib.mkIf config.custom.home-assistant.enable {
    services.home-assistant = {
      enable = true;
      openFirewall = true;
      extraComponents = [ "default_config" "met" "esphome" "homekit" ];

      config.default_config = { };
    };

    # Required for homekit component
    networking.firewall.allowedTCPPorts = [ 21064 ];
  };
}
