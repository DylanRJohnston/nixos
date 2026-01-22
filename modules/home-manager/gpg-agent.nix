{
  pkgs,
  lib,
  config,
  ...
}:
{
  options = {
    custom.gpg-agent.enable = lib.mkEnableOption "Enable gpg-agent";
  };

  config.services.gpg-agent = lib.mkIf config.custom.gpg-agent.enable {
    enable = true;

    enableSshSupport = true;

    pinentryPackage = pkgs.pinentry-curses;
  };
}
