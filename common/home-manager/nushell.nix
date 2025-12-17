{ lib, config, ... }:
{
  options.custom.modules.nushell.enable = lib.mkEnableOption "Enable Nushell module";

  config = lib.mkIf config.custom.modules.nushell.enable {
    programs.nushell = {
      enable = true;
      settings = {
        show_banner = false;
      };
    };

    programs.carapace = {
      enable = true;
      enableNushellIntegration = true;
    };

    programs.zoxide = {
      enable = true;
      enableNushellIntegration = true;
    };
  };
}
