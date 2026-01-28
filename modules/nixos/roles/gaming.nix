{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf (builtins.elem "gaming" config.custom.roles) {
    custom = {
      nvidia.enable = true;
      steam.enable = true;
    };
  };
}
