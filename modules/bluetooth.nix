{ arc, ... }:
{
  arc.base.includes = [
    arc.base._.bluetooth
  ];

  arc.base._.bluetooth.nixos.hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;

    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };

  arc.base._.bluetooth._.debug.nixos =
    { pkgs, ... }:
    {
      systemd.services.bluez-dbus-watch = {
        description = "Watch BlueZ D-Bus calls during boot";
        after = [
          "dbus.service"
          "bluetooth.service"
        ];
        wants = [ "bluetooth.service" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "simple";
          Restart = "always";
          RestartSec = 1;
          ExecStart = "${pkgs.dbus}/bin/dbus-monitor --system \"type='method_call',destination='org.bluez'\"";
        };
      };
    };
}
