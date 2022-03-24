{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.dylanj = { pkgs, ... }: {
    programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
      ];
    };

    programs.home-manager = {
      enable = true;
    };
  };
}


