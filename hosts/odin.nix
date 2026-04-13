{ arc, ... }:
{
  den.hosts.aarch64-darwin.odin = {
    users.dylanj.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGGm9bXqjKjMATEaJ0mcRIxVJ0bzJ3plmd3RZvvgwtPl dylanj@odin";

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
