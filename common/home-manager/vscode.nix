{ pkgs, ... }:
let
  extraExtensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      publisher = "rangav";
      name = "vscode-thunder-client";
      version = "1.16.2";
      sha256 = "mQwYvaMII+sG8OuCplk/P+3jMtlJbeNDJ/ItpnrIR/4=";
    }
    {
      publisher = "evzen-wybitul";
      name = "magic-racket";
      version = "0.6.4";
      sha256 = "Hxa4VPm3QvJICzpDyfk94fGHu1hr+YN9szVBwDB8X4U=";
    }
  ];
in
{
  programs.vscode =
    {
      enable = true;
      package = pkgs.vscode;

      mutableExtensionsDir = false;
      extensions = with pkgs.vscode-extensions; [
        _4ops.terraform
        arrterian.nix-env-selector
        dbaeumer.vscode-eslint
        eamodio.gitlens
        esbenp.prettier-vscode
        github.github-vscode-theme
        golang.go
        hashicorp.terraform
        jnoortheen.nix-ide
        matklad.rust-analyzer
        pkief.material-icon-theme
        streetsidesoftware.code-spell-checker
      ] ++ extraExtensions;

      keybindings = [
        { key = "ctrl+e"; command = "cursorLineEnd"; }
        { key = "ctrl+a"; command = "cursorLineStart"; }
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
          enableFiletypes = [
            "terraform"
          ];
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
}
