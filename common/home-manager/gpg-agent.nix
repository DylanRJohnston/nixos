{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    custom.modules.gpg-agent.enable = lib.mkEnableOption "Enable gpg-agent";
  };

  config.services.gpg-agent = lib.mkIf config.custom.modules.gpg-agent.enable {
    enable = true;

    enableSshSupport = true;

    pinentryPackage = pkgs.pinentry-curses;
  };
}
