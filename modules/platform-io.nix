let
  crossink-flash =
    {
      esptool,
      fetchurl,
      writeShellApplication,
    }:
    let
      firmware = fetchurl {
        url = "https://github.com/uxjulia/CrossInk/releases/download/v1.5.0/firmware-x3-x4-v1.5.0.bin";
        hash = "sha256-td6+i2s/JvGvU0EPOIouuN73ixmwwEqpTkbpQmhNzi8=";
      };
    in
    writeShellApplication {
      name = "crossink-flash";
      runtimeInputs = [ esptool ];
      text = ''
        port="''${1:-/dev/ttyACM0}"
        exec esptool \
          --chip esp32c3 \
          --port "$port" \
          --baud 921600 \
          write-flash 0x10000 ${firmware}
      '';
    };
in
{ den, arc, ... }:
{
  arc.development.includes = [ arc.development._.platform-io ];

  arc.development._.platform-io.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        platformio-core
        (callPackage crossink-flash { })
      ];
      services.udev.packages = with pkgs; [ platformio-core.udev ];
    };

  flake.packages = den.lib.withSystems [ "x86_64-linux" "aarch64-linux" ] (
    { pkgs, ... }:
    {
      crossink-flash = pkgs.callPackage crossink-flash { };
    }
  );
}
