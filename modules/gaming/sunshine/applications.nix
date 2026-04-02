{ arc, lib, ... }:
let
  games = ./games.json |> builtins.readFile |> builtins.fromJSON;
in
{
  arc.gaming._.sunshine = {
    includes = [
      arc.gaming._.sunshine._.definitions
      arc.gaming._.sunshine._.icons
    ];

    _.definitions.nixos =
      { config, pkgs, ... }:
      {
        services.sunshine.applications =
          let
            home = config.users.users.${config.system.primaryUser}.home;
            steam_app = steamid: name: {
              inherit name;
              image-path = "${home}/.config/sunshine/covers/${steamid}.png";
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

              for steamid in ${gameIds}; do
                input="$CACHE/$steamid/library_600x900.jpg"
                output="$OUT/$steamid.png"

                if [[ ! -f "$input" ]]; then
                    echo "Skipping $steamid, no library image found"
                    continue
                fi

                if [[ ! -f "$output" || "$input" -nt "$output" ]]; then
                  ${pkgs.imagemagick}/bin/magick convert "$input" "$output"
                  echo "Converted $steamid -> $output"
                fi
              done
            ''}";
      };
  };
}
