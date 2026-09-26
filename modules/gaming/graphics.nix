{ arc, nixosAspectTest, ... }:
{
  arc.gaming.nixos.hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  flake.tests.gaming-graphics = nixosAspectTest {
    baseline = [ arc.base ];
    aspects = [ arc.gaming ];
    expr =
      igloo:
      let
        extraPackageNames = map (
          package: package.pname or package.name
        ) igloo.hardware.graphics.extraPackages;
      in
      {
        enable = igloo.hardware.graphics.enable;
        enable32Bit = igloo.hardware.graphics.enable32Bit;
        nvidiaCompatibilityPackages = builtins.filter (
          name: name == "libva-vdpau-driver" || name == "libvdpau-va-gl"
        ) extraPackageNames;
        videoDrivers = igloo.services.xserver.videoDrivers;
      };
    enabled = {
      enable = true;
      enable32Bit = true;
      nvidiaCompatibilityPackages = [ ];
      videoDrivers = [
        "modesetting"
        "fbdev"
      ];
    };
    disabled = {
      enable = false;
      enable32Bit = false;
      nvidiaCompatibilityPackages = [ ];
      videoDrivers = [
        "modesetting"
        "fbdev"
      ];
    };
  };
}
