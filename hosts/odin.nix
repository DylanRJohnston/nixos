{ arc, ... }:
{
  den.hosts.aarch64-darwin.odin = {
    users.dylanj = { };

    aspects = with arc; [
      backup
      base
      development
      entertainment
      gaming
      mesh
    ];
  };
}
