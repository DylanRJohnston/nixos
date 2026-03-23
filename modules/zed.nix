{
  den.aspects.base.homeManager =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      options.custom.zed.config = lib.mkOption {
        type = lib.types.submodule {
          freeformType = lib.types.anything;
        };
      };

      config = {
        home.packages = [ pkgs.zed-editor ];

        custom.zed.config = {
          context_servers.context7 = {
            enabled = true;
            url = "https://mcp.context7.com/mcp";
          };

          agent = {
            default_profile = "ask";
            model_parameters = [ ];
            default_model = {
              effort = "medium";
              enable_thinking = true;
              provider = "zed.dev";
              model = "gpt-5.3-codex";
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

          ui_font_size = 16;
          buffer_font_size = 16;

          icon_theme = "Catppuccin Macchiato";
          theme = {
            dark = "Catppuccin Macchiato";
            mode = "dark";
            light = "Ayu Light";
          };

          buffer_font_family = "FiraCode Nerd Font Mono";

          languages = {
            Nix.language_servers = [
              "nixd"
              "!nil"
            ];
            TypeScript.code_actions_on_format = {
              "source.fixAll.eslint" = true;
            };
            Starlark.language_servers = [
              "starpls"
              "!tilt"
            ];
          };

          lsp.nixd.initialization_options.formatting.command = [ "nixfmt" ];

          auto_install_extensions =
            [
              "catppuccin"
              "catppuccin-icons"
              "cue"
              "cypher"
              "graphql"
              "helm"
              "html"
              "make"
              "nix"
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

        home.file.".config/zed/settings.json".text = lib.generators.toJSON { } config.custom.zed.config;
      };
    };
}
