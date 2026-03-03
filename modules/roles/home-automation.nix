{
  flake.modules.nixos.home-automation = {
    custom = {
      esphome.enable = true;
      home-assistant.enable = true;
    };
  };
}
