{ arc, ... }:
{
  den.hosts.aarch64-darwin.odin = {
    users.dylanj = { };

    aspects = [
      arc.backup
      arc.base
      arc.development
      arc.entertainment
      arc.gaming
      arc.mesh
    ];
  };
}
