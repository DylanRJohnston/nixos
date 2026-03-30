{ den, lib, ... }:
{
  den.aspects.gaming = {
    includes = [ den.aspects.gaming._.sunshine ];

    _.sunshine.nixos =
      { pkgs, config, ... }:
      {
        options.services.sunshine.global_prep_cmd = lib.mkOption {
          type = lib.types.listOf (
            lib.types.submodule {
              options = {
                do = lib.mkOption {
                  type = lib.types.str;
                };
                undo = lib.mkOption {
                  type = lib.types.str;
                };
              };
            }
          );
          default = [ ];
        };

        config.services.sunshine = {
          enable = true;
          autoStart = true;
          capSysAdmin = false;
          openFirewall = true;
          package = pkgs.sunshine.override { cudaSupport = true; };
          settings = {
            av1_mode = 0;
            encoder = "nvenc";
            hevc_mode = 0;
            global_prep_cmd = lib.strings.toJSON config.services.sunshine.global_prep_cmd;
          };
        };
      };
  };
}
