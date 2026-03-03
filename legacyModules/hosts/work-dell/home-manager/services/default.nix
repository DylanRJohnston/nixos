{ ... }:
{
  imports = [
    ./xss-lock.nix
  ];

  services.network-manager-applet.enable = true;
}
