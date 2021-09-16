{ pkgs, ... }: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "nix-ide";
        publisher = "jnoortheen";
        version = "0.1.16";
        sha256 = "04ky1mzyjjr1mrwv3sxz4mgjcq5ylh6n01lvhb19h3fmwafkdxbp";
      }
      {
        name = "rust-analyzer";
        publisher = "matklad";
        version = "0.2.735";
        sha256 = "0qr6aw99r95cdkmrryd5xm8ap3bf3kmisl4iph64ivvs833cmjk9";
      }
      {
        name = "nix-env-selector";
        publisher = "arrterian";
        version = "1.0.7";
        sha256 = "0mralimyzhyp4x9q98x3ck64ifbjqdp8cxcami7clvdvkmf8hxhf";
      }
      # Themes
      {
        name = "github-vscode-theme";
        publisher = "GitHub";
        version = "4.2.1";
        sha256 = "08n7jhm4ixfxjpfdwly6q15n4y3cga4r0qbl5qxh69s4c80370fh";
      }
    ];

    userSettings = {
      editor = {
        fontFamily = "FiraCode Nerd Font Mono";
        fontLigatures = true;
        tabSize = 2;
      };

      window.titlebarStyle = "custom";
      window.menuBarVisibility = "toggle";

      workbench = {
        colorTheme = "GitHub Dark Dimmed";
      };
    };
  };
}
