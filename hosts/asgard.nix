{ arc, ... }:
{
  den.hosts.aarch64-darwin.asgard = {
    users.dylanj.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGQYIShY4/BF912NKRcsr9evTDZ8L8o54Qad6qOx9BVw dylanj@asgard";

    aspects = [
      arc.backup
      arc.base
      arc.determinate
      arc.development
      arc.entertainment
      arc.gaming
      arc.mesh
      arc.secrets
    ];
  };
}
