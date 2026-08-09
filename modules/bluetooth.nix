{ arc, ... }:
{
  arc.base.includes = [
    arc.base._.bluetooth
  ];

  arc.base._.bluetooth.includes = [
    arc.base._.bluetooth._.high_quality_audio
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

  arc.base._.bluetooth._.high_quality_audio.nixos = {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;

      wireplumber.extraConfig = {
        "10-bluetooth-policy" = {
          "wireplumber.settings" = {
            # Switches profile from A2DP to HFP/HSP when an app requests the mic
            "bluetooth.autoswitch-to-headset-profile" = true;
          };
        };

        "20-bluetooth-codecs" = {
          "monitor.bluez.properties" = {
            "bluez5.roles" = [
              "a2dp_sink"
              "a2dp_source"
              "bap_sink"
              "bap_source"
              "hfp_hf"
              "hfp_ag"
            ];
            "bluez5.codecs" = [
              "sbc"
              "sbc_xq"
              "aac"
            ];
            "bluez5.hfphsp-backend" = "native";
          };
        };
      };
    };

    services.blueman.enable = true;
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
