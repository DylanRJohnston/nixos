let
  games = {
    "1086940" = "Baldur's Gate 3";
    "719040" = "Wasteland 3";
    "1091500" = "Cyberpunk 2077";
  };
in
{
  den.aspects.gaming = {
    nixos =
      {
        pkgs,
        lib,
        config,
        ...
      }:
      {
        services.sunshine = {
          enable = true;
          autoStart = true;
          capSysAdmin = false;
          openFirewall = true;
          package = pkgs.sunshine.override { cudaSupport = true; };
          settings = {
            av1_mode = 0;
            encoder = "nvenc";
            hevc_mode = 0;
            global_prep_cmd =
              let
                headless.enable = "swaymsg output HEADLESS-1 enable";
                headless.disable = "swaymsg output HEADLESS-1 disable";
                headless.set = "swaymsg output HEADLESS-1 mode \${SUNSHINE_CLIENT_WIDTH}x\${SUNSHINE_CLIENT_HEIGHT}@\${SUNSHINE_CLIENT_FPS}Hz";

                monitor.enable = "swaymsg output DP-1 enable";
                monitor.disable = "swaymsg output DP-1 disable";
              in
              lib.strings.toJSON [
                # Need to be careful to keep at least one display enabled at all times
                {
                  do = "sh -c \"${headless.enable}; ${headless.set}; ${monitor.disable}\"";
                  undo = "sh -c \"${monitor.enable}; ${headless.disable}\"";
                }
              ];
          };
          applications =
            let
              home = config.users.users.${config.system.primaryUser}.home;
              steam_app =
                let
                  width = "\${SUNSHINE_CLIENT_WIDTH}";
                  height = "\${SUNSHINE_CLIENT_HEIGHT}";
                  fps = "\${SUNSHINE_CLIENT_FPS}";
                in
                steamid: name: {
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
      };

    homeManager =
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
