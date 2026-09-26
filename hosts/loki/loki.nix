{ arc, ... }:
{
  den.hosts.x86_64-linux.loki = {
    users.dylanj.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFK2pIjOVUaMqazexDV1Cu6NVSq4cNxUkjLvTQVPzv6v dylanj@loki";

    aspects = [
      arc.base
      arc.determinate
      arc.development
      arc.entertainment
      arc.gaming
      arc.hardware._.nvidia
      arc.interactive
      arc.mesh
      # TODO: Refactor this into some kind of development module
      # needed for compiling for underpowered aarch64 on x86
      {
        nixos.boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
      }
      # TODO: Refactor this into some kind of usb / development module
      # needed for flashing firmware to usb devices (e.g. extink x3)
      {
        user.extraGroups = [ "dialout" ];
      }
    ];
  };
}
