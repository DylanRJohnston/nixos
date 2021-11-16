{
  environment.etc."machine-id".source = "/nix/persist/etc/machine-id";

  environment.etc."NetworkManager/system-connections".source = "/nix/persist/etc/NetworkManager/system-connections";
  systemd.tmpfiles.rules = [
    "L /var/lib/bluetooth - - - - /nix/persist/var/lib/bluetooth"
    "L /var/lib/systemd/coredump - - - - /nix/persist/var/lib/systemd/coredump"
    "L /var/log - - - - /nix/persist/var/log"
  ];
}
