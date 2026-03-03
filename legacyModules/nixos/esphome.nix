{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.custom.esphome;
in
{
  options.custom.esphome.enable = lib.mkEnableOption "Enable esphome service";

  config = lib.mkIf cfg.enable {
    services.esphome =
      let
        esphome-fhs = pkgs.buildFHSEnv {
          name = "esphome";
          targetPkgs =
            pkgs: with pkgs; [
              esphome
              python3
              git
              zlib
              glibc
              openssl
              libusb1
              udev
              gcc
              gnumake
            ];

          runScript = "esphome";
        };
      in
      {
        enable = true;
        package = esphome-fhs;
      };

    systemd.services.esphome.serviceConfig = {
      StateDirectory = "esphome";
      WorkingDirectory = "/var/lib/esphome";
      Environment = [
        "PLATFORMIO_CORE_DIR=/var/lib/esphome/.platformio"
        "PLATFORMIO_SETTINGS_ENABLE_TELEMETRY=No"
      ];

      NoNewPrivileges = lib.mkForce false;
      ProtectHome = lib.mkForce false;
      MountFlags = "shared";
    };
  };
}
