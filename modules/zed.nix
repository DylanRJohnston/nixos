{ arc, lib, ... }:
{
  arc.base.includes = [ arc.base._.zed ];

  arc.base._.zed = {
    includes = [
      arc.base._.zed._.agents
      arc.base._.zed._.context-servers
      arc.base._.zed._.misc
      arc.base._.zed._.nixd-config
      arc.base._.zed._.theme
      arc.base._.zed._.ssh
    ];

    homeManager =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      let
        # Write the Nix config to the store as compact JSON, then pretty-print
        # it with jq so the on-disk file is human-readable and comparisons are
        # stable regardless of how Zed reformats the file.
        settingsRaw = pkgs.writeText "zed-settings-raw.json" (
          lib.generators.toJSON { } config.programs.zed.config
        );
        settingsFile = pkgs.runCommand "zed-settings.json" { nativeBuildInputs = [ pkgs.jq ]; } ''
          jq . ${settingsRaw} > $out
        '';
        zedConfigDir = "${config.home.homeDirectory}/.config/zed";
        zedConfigPath = "${zedConfigDir}/settings.json";
      in
      {
        options.programs.zed.config = lib.mkOption {
          type = lib.types.submodule {
            freeformType = lib.types.anything;
          };
        };

        config.home.activation.zedSettings =
          lib.hm.dag.entryAfter [ "writeBoundary" ]
            "${pkgs.writeShellScript "zed-settings-sync" ''
              set -o nounset
              set -o pipefail

              ZED_CONFIG="${zedConfigPath}"
              NIX_CONFIG="${settingsFile}"

              if [ ! -f "$ZED_CONFIG" ]; then
                mkdir -p "${zedConfigDir}"
                cp "$NIX_CONFIG" "$ZED_CONFIG"
                chmod +w "$ZED_CONFIG"
                echo "Initialised $ZED_CONFIG from Nix config"
              else
                # Normalise key order and formatting before comparing so that
                # Zed reformatting the file doesn't produce spurious diffs.
                ZED_NORM=$(${pkgs.jq}/bin/jq --sort-keys . <(${pkgs.fixjson}/bin/fixjson "$ZED_CONFIG") 2>/dev/null)
                NIX_NORM=$(${pkgs.jq}/bin/jq --sort-keys . <(${pkgs.fixjson}/bin/fixjson "$NIX_CONFIG"))

                if [ "$ZED_NORM" != "$NIX_NORM" ]; then
                  echo ""
                  echo "WARNING: $ZED_CONFIG has drifted from the Nix config."
                  echo "Diff (a = on-disk, b = nix config):"
                  echo ""
                  ${pkgs.json-diff}/bin/json-diff --color \
                    <(echo "$ZED_NORM") \
                    <(echo "$NIX_NORM") \
                    || true
                  echo ""
                  echo "  To accept Zed's changes: update modules/zed.nix to match."
                  echo "  To reset to Nix config:  cp ${settingsFile} $ZED_CONFIG"
                  echo ""
                fi
              fi
            ''}";
      };

    _.nixd-config =
      { host, ... }:
      {
        homeManager =
          { config, ... }:
          {
            options.programs.zed.nixd.hostConfigPath = lib.mkOption {
              type = lib.types.path;
              default = "${config.home.homeDirectory}/.nixpkgs";
            };

            config.programs.zed.config = {
              languages.Nix.language_servers = [
                "nixd"
                "!nil"
              ];
              lsp.nixd.initialization_options =
                let
                  flake = "(builtins.getFlake \"${config.programs.zed.nixd.hostConfigPath}\")";
                in
                {
                  autowatch = true;
                  formatting.command = [ "nixfmt" ];
                  diagnostics.suppress = [ ];
                  nixpkgs.expr = "import ${flake}.inputs.nixpkgs {}";
                  options.nixos.expr = "${flake}.${host.class}Configurations.${host.name}.options";
                  options.homeManager.expr = "${flake}.${host.class}Configurations.${host.name}.options.home-manager.users.type.getSubOptions []";
                };
            };
          };
      };

    _.context-servers.homeManager.programs.zed.config.context_servers.context7 = {
      enabled = true;
      url = "https://mcp.context7.com/mcp";
    };

    _.agents.homeManager.programs.zed.config.agent = {
      dock = "right";
      sidebar_side = "right";
      default_profile = "write";
      model_parameters = [ ];
      default_model = {
        effort = "high";
        enable_thinking = true;
        provider = "zed.dev";
        model = "gpt-5.5-pro";
      };
      profiles = {
        ask = {
          name = "Ask";
          enable_all_context_servers = true;
        };
        write = {
          name = "Write";
          enable_all_context_servers = true;
        };
      };
    };

    _.theme.homeManager.programs.zed.config = {
      ui_font_size = 16;
      buffer_font_size = 16;

      icon_theme = "Catppuccin Macchiato";
      theme = {
        dark = "Catppuccin Macchiato";
        mode = "dark";
        light = "Ayu Light";
      };

      buffer_font_family = "FiraCode Nerd Font Mono";

      auto_install_extensions = {
        catppuccin = true;
        catppuccin-icons = true;
      };

      project_panel.dock = "left";
      outline_panel.dock = "left";
      collaboration_panel.dock = "left";
      git_panel.dock = "left";
    };

    _.misc.homeManager.programs.zed.config = {
      diagnostics.inline.enabled = true;
      inlay_hints.enabled = true;

      languages = {
        TypeScript.code_actions_on_format = {
          "source.fixAll.eslint" = true;
        };
        Starlark.language_servers = [
          "starpls"
          "!tilt"
        ];
      };

      auto_install_extensions =
        [
          "cue"
          "cypher"
          "graphql"
          "helm"
          "html"
          "make"
          "rust"
          "starlark"
          "toml"
        ]
        |> lib.map (name: {
          inherit name;
          value = true;
        })
        |> lib.listToAttrs;
    };

    _.ssh.homeManager.programs.zed.config = {
      # TODO make this derived from den.hosts
      ssh_connections = [
        {
          host = "mimir";
          args = [ ];
          projects = [
            {
              paths = [ "/etc/nixos" ];

            }
          ];
        }
        {
          host = "loki";
          args = [ ];
          projects = [
            {
              paths = [ "/home/dylanj/.nixpkgs" ];
            }
          ];
        }
      ];
    };
  };
}
