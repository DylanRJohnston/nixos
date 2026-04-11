{
  den,
  arc,
  lib,
  ...
}:
let
  games = {
    "1086940" = "Baldur's Gate 3";
    "719040" = "Wasteland 3";
    "1091500" = "Cyberpunk 2077";
  };
in
{
  arc.gaming._.sunshine = {
    includes = [
      arc.gaming._.sunshine._.definitions
      arc.gaming._.sunshine._.icons
    ];

    _.definitions = den.lib.perHost (
      { host }:
      {
        nixos =
          { pkgs, ... }:
          {
            services.sunshine.applications =
              let
                steam_app = steamid: name: {
                  inherit name;
                  image-path = "${host.primaryUser.home}/.config/sunshine/covers/${steamid}.png";
                  output = "/tmp/${steamid}.log";
                  cmd = "steam steam://rungameid/${steamid}";
                };
                steam_apps = lib.mapAttrsToList steam_app games;
                other_apps = [
                  {
                    name = "Desktop";
                    image-path = "desktop.png";
                  }
                  {
                    name = "Steam Big Picture";
                    cmd = "steam -tenfoot -pipewire-dmabuf";
                  }
                ];
              in
              {
                apps = steam_apps ++ other_apps;
                env = {
                  PATH = "$(PATH):${pkgs.gamescope}/bin:${pkgs.sway}/bin:${pkgs.bash}/bin:${pkgs.util-linux}/bin:${pkgs.xdg-utils}/bin:${pkgs.steam}/bin:${pkgs.sudo}/bin";
                };
              };
          };
      }
    );

    _.icons.homeManager =
      { lib, pkgs, ... }:
      {
        home.activation.sunshineIcons =
          let
            gameIds = games |> builtins.attrNames |> lib.strings.join " ";
          in
          lib.hm.dag.entryAfter [ "writeBoundary" ]
            "${pkgs.writeShellScript "rebuild-sunshine-icons" ''
              set -o nounset
              set -o errexit
              set -o pipefail

              echo "Rebuilding Sunshine Icons"

              CACHE="$HOME/.local/share/Steam/appcache/librarycache"
              OUT="$HOME/.config/sunshine/covers/"

              mkdir -p "$OUT"
              for STEAM_ID in ${gameIds}; do
                  INPUT=""
                  PRIMARY_INPUT="$CACHE/$STEAM_ID/library_600x900.jpg"

                  if [[ -f "$PRIMARY_INPUT" ]]; then
                    INPUT="$PRIMARY_INPUT"
                  else
                    FALLBACK_INPUT="$(${pkgs.findutils}/bin/find "$CACHE/$STEAM_ID" -type f -name "library_capsule.jpg" -print -quit 2>/dev/null || true)"

                    if [[ -n "$FALLBACK_INPUT" && -f "$FALLBACK_INPUT" ]]; then
                        INPUT="$FALLBACK_INPUT"
                    fi
                  fi

                  if [[ -z "$INPUT" ]]; then
                    echo "Skipping $STEAM_ID, no library image found (checked library_600x900.jpg and library_capsule.jpg)"
                    continue
                  fi

                  OUTPUT="$OUT/$STEAM_ID.png"
                  if [[ ! -f "$OUTPUT" || "$INPUT" -nt "$OUTPUT" ]]; then
                    ${pkgs.imagemagick}/bin/magick convert "$INPUT" "$OUTPUT"
                    echo "Converted $STEAM_ID from $INPUT -> $OUTPUT"
                  fi
              done
            ''}";
      };
  };
}
