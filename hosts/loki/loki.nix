{ arc, ... }:
{
  den.hosts.x86_64-linux.loki = {
    users.dylanj.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFK2pIjOVUaMqazexDV1Cu6NVSq4cNxUkjLvTQVPzv6v dylanj@loki";

    aspects = [
      arc.base
      arc.development
      arc.entertainment
      arc.gaming
      arc.home-automation
      arc.mesh
      {
        nixos.boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
      }
    ];
  };
}
