{
  inputs,
  arc,
  ...
}:
{
  den.hosts.aarch64-linux.mimir = {
    boot = arc.bootloader._.sd-card;
    flake = "/etc/nixos";

    users.dylanj.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEiryutR7xApg8zJgUkquBV20JaLm93GSHh2kNg95fAn dylanj@mimir";

    aspects = [
      arc.base
      arc.determinate
      arc.hardware._.raspberry-pi
      arc.home-automation
      arc.media-server
      arc.mesh
      arc.remote-builders
    ];
  };
}
