{
  imports = [
    ./compton.nix
    ./gpg-agent.nix
    ./i3.nix
    ./xss-lock.nix
  ];

  services.network-manager-applet.enable = true;
}
