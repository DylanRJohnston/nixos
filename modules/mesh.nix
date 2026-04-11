{ arc, ... }:
{
  arc.mesh.includes = [
    arc.mesh._.tailscale
  ];

  arc.mesh._.tailscale.os.services.tailscale.enable = true;
}
