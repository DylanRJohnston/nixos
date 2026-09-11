{ lib, ... }:
{
  arc.schema.host.options.bulkStoragePath = lib.mkOption {
    type = lib.types.nullOr (lib.types.strMatching "/.*");
    default = null;
    example = "/mnt/storage";
    description = "Absolute path to this host's bulk persistent storage";
  };
}
