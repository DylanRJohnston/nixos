{
  pkgs,
  lib,
  config,
  ...
}:
let
  prepackagedExtensions = with pkgs.vscode-extensions; [
    _4ops.terraform
    dbaeumer.vscode-eslint
    eamodio.gitlens
    esbenp.prettier-vscode
    github.github-vscode-theme
    golang.go
    hashicorp.terraform
    jnoortheen.nix-ide
    marp-team.marp-vscode
    matklad.rust-analyzer
    ms-azuretools.vscode-docker
    pkief.material-icon-theme
    streetsidesoftware.code-spell-checker
    redhat.vscode-yaml
  ];

  otherExtensions = lib.attrsets.mapAttrsToList (
    key: sha256:
    let
      data = builtins.elemAt (builtins.elemAt (builtins.split "(.+)\\.(.+)#(.+)" key) 1);
      publisher = data 0;
      name = data 1;
      version = data 2;
    in
    {
      inherit
        name
        publisher
        version
        sha256
        ;
    }
  );

  manualExtensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace (otherExtensions {
    "akamud.vscode-theme-onedark#2.2.3" = "tfAhPTtOAYDU35UYMK6IRwWwh8r60DrAglBv1M81ztQ=";
    "be5invis.toml#0.6.0" = "yk7buEyQIw6aiUizAm+sgalWxUibIuP9crhyBaOjC2E=";
    "ethan-reesor.vscode-go-test-adapter#0.1.6" = "Aj5W2flMv0DVaNJAHBuPb1SQlTq5K+7QLKzDWpR2CY8=";
    "evzen-wybitul.magic-racket#0.6.4" = "Hxa4VPm3QvJICzpDyfk94fGHu1hr+YN9szVBwDB8X4U=";
    "hbenl.vscode-test-explorer#2.21.1" = "fHyePd8fYPt7zPHBGiVmd8fRx+IM3/cSBCyiI/C0VAg=";
    "mkhl.direnv#0.6.1" = "5/Tqpn/7byl+z2ATflgKV1+rhdqj+XMEZNbGwDmGwLQ=";
    "ms-vscode.live-server#0.2.12" = "4rNz8u7Ff5ZTkF+4+OcrhO/o9Aqi3wa5SdTKkGhgsEQ=";
    "ms-vscode.test-adapter-converter#0.1.6" = "UC8tUe+JJ3r8nb9SsPlvVXw74W75JWjMifk39JClRF4=";
    "ryanluker.vscode-coverage-gutters#2.10.1" = "xamJkgx8P4W/lB8Q2SBE0c6Iiurp8sO1uEEei1Zqc+s=";
  });
in
{

  options.custom.modules.vscode.enable = lib.mkEnableOption "Enable vscode configuration";

  config.programs.vscode = lib.mkIf config.custom.modules.vscode.enable {
    # Use VSCode setting sync instead
    enable = false;
    package = pkgs.vscode;
    mutableExtensionsDir = false;

    profiles.default = {

      extensions = prepackagedExtensions ++ manualExtensions;

      keybindings = [
        {
          key = "ctrl+e";
          command = "cursorLineEnd";
        }
        {
          key = "ctrl+a";
          command = "cursorLineStart";
        }
      ];

      userSettings = {
        update.mode = "manual";
        editor = {
          fontFamily = "FiraCode Nerd Font Mono";
          fontLigatures = true;
          tabSize = 2;
          formatOnSave = true;
          codeActionsOnSave.source.fixAll = true;
          bracketPairColorization.enabled = true;
          guides.bracketPairs = "active";
          minimap.enabled = false;
        };

        cSpell = {
          enabled = true;
          language = "en-GB";
          enableFiletypes = [ "terraform" ];
        };

        window.titlebarStyle = "custom";
        window.menuBarVisibility = "toggle";

        workbench = {
          colorTheme = "GitHub Dark";
          iconTheme = "material-icon-theme";
        };

        "[typescript]" = {
          editor.defaultFormatter = "esbenp.prettier-vscode";
        };
      };
    };
  };
}
