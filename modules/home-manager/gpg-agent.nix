{
  flake.modules.homeManager.disabled =
    { pkgs, ... }:
    {
      services.gpg-agent = {
        enable = true;
        enableSshSupport = true;
        pinentryPackage = pkgs.pinentry-curses;
      };
    };
}
