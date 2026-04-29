let
  chip-ota-provider-app =
    {
      fetchurl,
      stdenv,
      glibc,
      libnl,
      autoPatchelfHook,
      writeShellScriptBin,
    }:
    let
      raw = fetchurl {
        url = "https://github.com/home-assistant-libs/matter-linux-ota-provider/releases/download/2025.9.0/chip-ota-provider-app-aarch64";
        sha256 = "4GirbEBQ4j6qbM2pv37M3Et5KiUU4QmMvBK0FM1kqn4=";
      };

      patched = stdenv.mkDerivation {
        name = "chip-ota-provider-app";
        version = "2025.9.0";
        src = raw;
        dontUnpack = true;

        nativeBuildInputs = [ autoPatchelfHook ];
        buildInputs = [
          glibc
          stdenv.cc.cc.lib
          libnl
        ];

        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin
          cp ${raw} $out/bin/chip-ota-provider-app
          chmod +x $out/bin/chip-ota-provider-app
          runHook postInstall
        '';
      };
    in
    writeShellScriptBin "chip-ota-provider-app" ''
      set -eo pipefail
      args=()
      while (( $# )); do
        if [[ "$1" == "--secured-device-port" && "''${2-}" == "0" ]]; then
          args+=( "--secured-device-port" "5540" )
          shift 2
        else
          args+=( "$1" )
          shift
        fi
      done

      exec ${patched}/bin/chip-ota-provider-app "''${args[@]}"
    '';
in
{ den, arc, ... }:
{
  arc.home-automation.includes = [ arc.home-automation._.matter ];

  arc.home-automation._.matter.nixos =
    { pkgs, ... }:
    {
      services.matter-server.enable = true;
      services.tailscale-serve."matter".target = "127.0.0.1:5580";
      systemd.services.matter-server.path = [ (pkgs.callPackage chip-ota-provider-app { }) ];
      networking.firewall.allowedUDPPorts = [ 5540 ];
    };

  flake.packages = den.lib.withSystems [ "x86_64-linux" "aarch64-linux" ] (
    { pkgs, ... }:
    {
      chip-ota-provider-app = pkgs.callPackage chip-ota-provider-app { };
    }
  );
}
