{ lib, config, ... }:
{
  options.custom.nushell.enable = lib.mkEnableOption "Enable Nushell module";

  config = lib.mkIf config.custom.nushell.enable {
    programs.carapace = {
      enable = true;
      enableNushellIntegration = true;
    };

    programs.zoxide = {
      enable = true;
      enableNushellIntegration = true;
    };

    programs.nushell = {
      enable = true;
      settings = {
        show_banner = false;
      };

      shellAliases = {
        gitlog = "git log --oneline --decorate --graph --all";
        ll = "ls -la";
      };

    };

  };
}
