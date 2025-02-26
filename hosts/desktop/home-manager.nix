{ pkgs, common, ... }:
{
  imports = with common; [
    base
    vscode-server-wsl
  ];
}
