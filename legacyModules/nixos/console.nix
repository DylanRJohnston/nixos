{ lib, config, ... }:
{
  options.custom.console.enable = lib.mkEnableOption "Enable custom console";
  config = lib.mkIf config.custom.console.enable {
    console.font = "Lat2-Terminus16";
    console.colors = [
      "073642"
      "dc322f"
      "859900"
      "b58900"
      "268bd2"
      "d33682"
      "2aa198"
      "fdf6e3"
      "002b36"
      "cb4b16"
      "657b83"
      "839496"
      "93a1a1"
      "6c71c4"
      "eee8d5"
      "fdf6e3"
    ];
  };
}
