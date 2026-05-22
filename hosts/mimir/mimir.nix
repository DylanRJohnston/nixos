{
  inputs,
  arc,
  ...
}:
{
  den.hosts.aarch64-linux.mimir = {
    flake = "/etc/nixos";

    boot = arc.bootloader._.sd-card;

    hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHvc+Hg96cc3wNxVLeJzHzAYtGQMGY97MbFnRkXbqkns root@mimir";
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
