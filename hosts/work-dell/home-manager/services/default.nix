{ common, ... }:
{
  imports = with common; [
    compton
    gpg-agent
    i3
    ./xss-lock.nix
  ];

  services.network-manager-applet.enable = true;
}
