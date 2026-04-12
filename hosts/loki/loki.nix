{ arc, ... }:
{
  den.hosts.x86_64-linux.loki = {
    users.dylanj = { };

    aspects = [
      arc.base
      arc.development
      arc.entertainment
      arc.gaming
      arc.home-automation
      arc.mesh
    ];
  };
}
