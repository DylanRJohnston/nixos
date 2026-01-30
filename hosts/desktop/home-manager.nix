{ pkgs, ... }: {
  home.packages = with pkgs; [
    firefox
    spotify
    zed-editor
  ];

  programs.zed-editor = {
    enable = true;
    extensions = [ "nix" "toml" "rust" ];
  };
}
