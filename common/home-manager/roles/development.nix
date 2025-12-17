{
  lib,
  osConfig,
  pkgs,
  ...
}:
{
  config = lib.mkIf (builtins.elem "development" osConfig.custom.roles) {
    home.packages = with pkgs; [
      awscli2
      binaryen
      kubectl
      kubectx
      nmap
    ];

    custom.modules = {
      nushell.enable = true;
    };
  };
}
