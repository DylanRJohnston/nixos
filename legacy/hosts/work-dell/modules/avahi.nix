{ ... }:
{
  # Enable Multicast DNS and publish the host.
  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      domain = true;
      addresses = true;
    };
  };
}
