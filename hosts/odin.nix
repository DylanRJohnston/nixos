{ arc, ... }:
{
  den.hosts.aarch64-darwin.odin = {
    users.dylanj = { };

    aspects = with arc; [
      base
      backup
      development
      entertainment
      gaming
      mesh
    ];
  };
}
