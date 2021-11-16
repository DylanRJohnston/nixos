{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    extensions = with pkgs.vscode-extensions; [
      esbenp.prettier-vscode
      jnoortheen.nix-ide
      # matklad.rust-analyzer
      arrterian.nix-env-selector
      dbaeumer.vscode-eslint
      github.github-vscode-theme
      pkief.material-icon-theme
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
      name = "rust-analyzer";
      publisher = "matklad";
      version = "0.2.801";
      sha256 = "FcJhoFvSQU4362Ubzmuyn12W1G3rWR/vvFNXXnS0mqY=";
    }];

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
      };

      window.titlebarStyle = "custom";
      window.menuBarVisibility = "toggle";

      workbench = {
        colorTheme = "Solarized Dark";
        iconTheme = "material-icon-theme";
      };

      "[typescript]" = {
        editor.defaultFormatter = "esbenp.prettier-vscode";
      };
    };
  };
}
