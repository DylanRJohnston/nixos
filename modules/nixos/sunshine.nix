{
  den.aspects.gaming.nixos =
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
