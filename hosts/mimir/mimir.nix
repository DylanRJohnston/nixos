{
  arc,
  den,
  ...
}:
{
  den.hosts.aarch64-linux.mimir = {
    flake = "/etc/nixos";
    bulkStoragePath = "/mnt/external";

    boot = arc.bootloader._.sd-card;

    hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHvc+Hg96cc3wNxVLeJzHzAYtGQMGY97MbFnRkXbqkns root@mimir";
    users.dylanj.config.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEiryutR7xApg8zJgUkquBV20JaLm93GSHh2kNg95fAn dylanj@mimir";

    aspect.includes = [
      den.aspects.mimir
      arc.base
      arc.determinate
      arc.hardware._.raspberry-pi
      arc.home-automation
      arc.media-server
      arc.mesh
      arc.monitoring
      arc.remote-builders
      arc.secrets
      arc.public-ingress
    ];
  };
}
