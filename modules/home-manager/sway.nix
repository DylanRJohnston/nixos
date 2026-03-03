{
  flake.modules.nixos.base.home =
    {
      config,
      ...
    }:
    {
      home.file.".config/sway/config".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nixpkgs/mutable/sway.config";
    };
}
