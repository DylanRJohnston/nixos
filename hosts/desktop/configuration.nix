{ kit, ... }:
{
  den.hosts.x86_64-linux.desktop = {
    users.dylanj = { };

    roles = with kit; [
      base
      development
      entertainment
      gaming
      home-automation
    ];
  };

  den.aspects.desktop.nixos = {
    networking.hostName = "desktop";

    services.fstrim.enable = true;
    services.sunshine.defaultAudioSink = "alsa_output.pci-0000_2b_00.4.analog-stereo";
  };
}
