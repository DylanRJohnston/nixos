let
  chip-ota-provider-app =
    pkgs:
    let
      raw = pkgs.fetchurl {
        url = "https://github.com/home-assistant-libs/matter-linux-ota-provider/releases/download/2025.9.0/chip-ota-provider-app-aarch64";
        sha256 = "4GirbEBQ4j6qbM2pv37M3Et5KiUU4QmMvBK0FM1kqn4=";
      };

      patched = pkgs.stdenvNoCC.mkDerivation {
        name = "chip-ota-provider-app";
        version = "2025.9.0";
        src = raw;
        dontUnpack = true;

        nativeBuildInputs = [ pkgs.autoPatchelfHook ];
        buildInputs = [
          pkgs.glibc
          pkgs.stdenv.cc.cc.lib
          pkgs.libnl
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
    pkgs.writeShellScriptBin "chip-ota-provider-app" ''
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
      systemd.services.matter-server.path = [ (chip-ota-provider-app pkgs) ];
      networking.firewall.allowedUDPPorts = [ 5540 ];
    };

  flake = den.lib.perSystem (
    { pkgs, ... }:
    {
      packages.chip-ota-provider-app = chip-ota-provider-app pkgs;
    }
  );
}
