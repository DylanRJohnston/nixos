{ pkgs, ... }:
let
  patch = pkgs.fetchFromGitHub {
    # https://github.com/sonowz/vscode-remote-wsl-nixos
    owner = "sonowz";
    repo = "vscode-remote-wsl-nixos";
    rev = "e5dded6ee6e214fbf14a88f58775334ca5c19571";
    sha256 = "UcO4S0HqabTPu6wnB/fuWWdtKGFmf9fpWRuLUwGHo6o=";
  };
in
{
  home.file.".vscode-server/server-env-setup".source = "${patch}/flake/server-env-setup";
}
