{ config, lib, ... }:
{
  options.custom.modules.zed.enable = lib.mkEnableOption "Enable Zed module";

  config = lib.mkIf config.custom.modules.zed.enable {
    home.file.".config/zed/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nixpkgs/mutable/zed/settings.json";
  };
}
