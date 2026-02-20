{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (builtins.elem "home-automation" config.custom.roles) {
    custom = {
      esphome.enable = true;
      home-assistant.enable = true;
      # Not required with direct homekit integration from home-assistant
      # TODO: Remove module
      # homebridge.enable = true;
    };
  };
}
