{
  inputs,
  ...
}:
{
  arc.hardware._.raspberry-pi.nixos = { lib, ... }: {
    imports =
      with inputs.raspberry-pi.nixosModules;
      with raspberry-pi-4;
      with inputs.raspberry-pi.lib;
      [
        base
        bluetooth
        inject-overlays
        inject-overlays-global
        nixpkgs-rpi
        trusted-nix-caches
        usb-gadget-ethernet
        sd-image
      ];

      boot.supportedFilesystems.zfs = lib.mkForce false;

      # Needs to be injected for the above modules to find the flake
      _module.args.nixos-raspberrypi = inputs.raspberry-pi;
  };
}
