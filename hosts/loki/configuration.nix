{ arc, ... }:
{
  den.hosts.x86_64-linux.loki = {
    users.dylanj = { };

    aspects = with arc; [
      base
      development
      entertainment
      gaming
      home-automation
      mesh
    ];
  };
}
