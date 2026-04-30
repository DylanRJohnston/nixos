{
  inputs,
  arc,
  ...
}:
{
  den.hosts.aarch64-linux.mimir = {
    boot = arc.bootloader._.sd-card;
    flake = "/etc/nixos";

    users.dylanj.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEiryutR7xApg8zJgUkquBV20JaLm93GSHh2kNg95fAn dylanj@mimir";

    aspects = [
      arc.base
      arc.home-automation
      arc.media-server
      arc.mesh
      arc.remote-builders
      {
        nixos =
          { pkgs, ... }:
          {
            imports = [
              inputs.hardware.nixosModules.raspberry-pi-4
            ];

            # Issue https://github.com/NixOS/nixpkgs/issues/126755#issuecomment-869149243
            nixpkgs.overlays = [
              (final: super: {
                makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
              })
            ];

            hardware.raspberry-pi."4" = {
              fkms-3d.enable = true;
            };
          };
      }
    ];
  };
}
