{ pkgs, ... }:
{
  programs.vscode =
    {
      enable = true;
      package = pkgs.vscode;

      extensions = with pkgs.vscode-extensions; [
        esbenp.prettier-vscode
        jnoortheen.nix-ide
        matklad.rust-analyzer
        arrterian.nix-env-selector
        dbaeumer.vscode-eslint
        github.github-vscode-theme
        pkief.material-icon-theme
        eamodio.gitlens
        hashicorp.terraform
        _4ops.terraform
        golang.go
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
