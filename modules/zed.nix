{ kit, lib, ... }:
{
  flake.kit = kit;

  kit.base.includes = [ kit.base._.zed ];

  kit.base._.zed = {
    includes = [
      kit.base._.zed._.agents
      kit.base._.zed._.context-servers
      kit.base._.zed._.misc
      kit.base._.zed._.nixd-config
      kit.base._.zed._.theme
    ];

    homeManager =
      { config, pkgs, ... }:
      {
        options.programs.zed.config = lib.mkOption {
          type = lib.types.submodule {
            freeformType = lib.types.anything;
          };
        };

        config = {
          home.packages = [ pkgs.zed-editor ];

          home.file.".config/zed/settings.json".text = lib.generators.toJSON { } config.programs.zed.config;
        };
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
                  flake = "(builtins.getFlake ${config.programs.zed.nixd.hostConfigPath})";
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
      settings = { };
    };

    _.agents.homeManager.programs.zed.config.agent = {
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
    };

    _.misc.homeManager.programs.zed.config = {
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
  };
}
