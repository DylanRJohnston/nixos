{ config, ... }:
{
  home.file.".config/zed/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nixpkgs/mutable/zed/settings.json";
}
