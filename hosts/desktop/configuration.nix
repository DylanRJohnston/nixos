{ kit, ... }:
{
  den.hosts.x86_64-linux.desktop = {
    users.dylanj = { };

    roles = with kit; [
      base
      development
      entertainment
      gaming
      home-automation
    ];
  };

  den.aspects.desktop.nixos = {
    networking.hostName = "desktop";

    services.fstrim.enable = true;
  };
}
