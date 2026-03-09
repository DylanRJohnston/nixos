{
  flake.modules.nixos.base =
    { config, ... }:
    {
      users.users.${config.system.primaryUser} = {
        isNormalUser = true;
        description = "Dylan Johnston";
        extraGroups = [
          "networkmanager"
          "wheel"
          "video"
          "render"
        ];
      };
    };
}
