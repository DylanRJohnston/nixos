{ modules, ... }:
{
  imports = [ modules.vscode-server ];

  services.vscode-server.enable = true;
}
