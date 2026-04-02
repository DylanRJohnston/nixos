{ arc, ... }:
{
  arc.base.includes = [
    arc.base._.network-manager
    arc.base._.hostname
  ];

  arc.base._.network-manager = {
    nixos.networking.networkmanager.enable = true;
  };

  arc.base._.hostname =
    { host }:
    {
      os.networking.hostName = host.name;
    };
}
