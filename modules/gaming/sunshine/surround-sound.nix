{ kit, ... }:
{
  kit.gaming._.sunshine = {
    includes = [ kit.gaming._.sunshine._.surround-sound ];

    _.surround-sound.nixos =
      {
        pkgs,
        lib,
        config,
        ...
      }:
      {
        options.services.sunshine.defaultAudioSink = lib.mkOption {
          type = lib.types.str;
          description = "Audio sink to restore when not streaming";
        };

        config = {
          environment.systemPackages = with pkgs; [
            alsa-utils
            pulseaudio
          ];

          security.rtkit.enable = true;
          services.pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
          };

          services.sunshine = {
            settings.audio_sink = "surround51";
            global_prep_cmd = [
              {
                do = "${pkgs.writeShellScript "sunshine-surround-sound-prep" ''
                  #!/bin/sh
                  pactl load-module module-null-sink \
                    sink_name=surround51 \
                    channels=6 \
                    channel_map=front-left,front-right,front-center,lfe,rear-left,rear-right

                  pactl set-default-sink surround51

                  for input in $(pactl list short sink-inputs | cut -f1); do
                    pactl move-sink-input "$input" surround51
                  done
                ''}";
                undo = "${pkgs.writeShellScript "sunshine-surround-sound-undo" ''
                  #!/bin/sh
                  REAL="${config.services.sunshine.defaultAudioSink}"

                  pactl set-default-sink "$REAL"

                  for input in $(pactl list short sink-inputs | cut -f1); do
                    pactl move-sink-input "$input" "$REAL"
                  done

                  # unload virtual sink
                  for id in $(pactl list short modules | grep module-null-sink | cut -f1); do
                    pactl unload-module "$id"
                  done
                ''}";
              }
            ];
          };
        };
      };
  };
}
