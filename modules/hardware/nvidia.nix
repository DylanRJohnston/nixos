{ arc, nixosAspectTest, ... }:
{
  arc.hardware._.nvidia.nixos =
    {
      pkgs,
      ...
    }:
    {
      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          libva-vdpau-driver
          libvdpau-va-gl
        ];
      };

      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.nvidia = {
        modesetting.enable = true;
        open = true;
        # Preserve GPU contexts; the 595+ open driver uses the kernel suspend
        # notifier instead of the legacy systemd hooks.
        powerManagement.enable = true;
      };
    };

  flake.tests.nvidia-profile = nixosAspectTest {
    baseline = [ arc.base ];
    aspects = [ arc.hardware._.nvidia ];
    expr =
      igloo:
      let
        extraPackageNames = map (
          package: package.pname or package.name
        ) igloo.hardware.graphics.extraPackages;
      in
      {
        graphicsEnable = igloo.hardware.graphics.enable;
        hasLibvaVdpauDriver = builtins.elem "libva-vdpau-driver" extraPackageNames;
        hasLibvdpauVaGl = builtins.elem "libvdpau-va-gl" extraPackageNames;
        modesetting = igloo.hardware.nvidia.modesetting.enable;
        open = igloo.hardware.nvidia.open;
        powerManagement = igloo.hardware.nvidia.powerManagement.enable;
        kernelSuspendNotifier = igloo.hardware.nvidia.powerManagement.kernelSuspendNotifier;
        preserveVideoMemoryAllocations =
          igloo.hardware.nvidia.moduleParams.nvidia.NVreg_PreserveVideoMemoryAllocations or null;
        useKernelSuspendNotifiers =
          igloo.hardware.nvidia.moduleParams.nvidia.NVreg_UseKernelSuspendNotifiers or null;
        videoDrivers = igloo.services.xserver.videoDrivers;
      };
    enabled = {
      graphicsEnable = true;
      hasLibvaVdpauDriver = true;
      hasLibvdpauVaGl = true;
      modesetting = true;
      open = true;
      powerManagement = true;
      kernelSuspendNotifier = true;
      preserveVideoMemoryAllocations = 1;
      useKernelSuspendNotifiers = 1;
      videoDrivers = [ "nvidia" ];
    };
    disabledErr.msg = "expected a set but found null";
  };
}
