{
  flake.modules.nixos.gaming =
    {
      pkgs,
      ...
    }:
    {
      services.sunshine = {
        enable = true;
        autoStart = true;
        capSysAdmin = true;
        openFirewall = true;
        package = pkgs.sunshine.override { cudaSupport = true; };
      };
    };
}
