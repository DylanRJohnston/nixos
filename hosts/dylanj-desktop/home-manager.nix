{ pkgs, ... }: {
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.nixos = {
    imports = [
      ../../common/home-manager/alacritty.nix
      ../../common/home-manager/direnv.nix
      ../../common/home-manager/git.nix
      ../../common/home-manager/vim.nix
      ../../common/home-manager/vscode.nix
      ../../common/home-manager/zsh.nix
      ../../common/home-manager/tmux.nix
    ];

    home.packages = with pkgs; [
      fzf
      git-town
      htop
      iftop
      jq
      killall
      lsof
      ngrok
      nixpkgs-fmt
      tmux
    ];

    programs.home-manager = {
      enable = true;
    };
  };
}
