{ pkgs, ... }:
{
  programs.vscode =
    {
      enable = true;
      package = pkgs.vscode;

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
      ];

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
