{
  arc.base.nixos.hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;

    disabledPlugins = [ "policy" ];

    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
      Policy = {
        AutoEnable = true;
        # ReconnectUUIDs = "";
      };
    };
  };
}
