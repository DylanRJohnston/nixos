{ pkgs, ... }:
{
  sound.enable = true;

  # High quality BT calls
  hardware.bluetooth.enable = true;
  hardware.bluetooth.hsphfpd.enable = false;

  # Pipewire config
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    # No idea if I need this
    alsa.support32Bit = true;
    pulse.enable = true;
  };

}
