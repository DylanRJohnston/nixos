{ common, ... }:
{
  imports = [
    common.base
    common.nix-daemon
  ];

  homebrew.casks = [
   "audacity"
   "backblaze"
   "cyberduck"
   "discord"
   "gimp"
   "jellyfin"
   "openmtp"
   "openvpn-connect"
   "signal"
   "slack"
   "steam"
   "transmission"
   "visual-studio-code"
   "vlc"
  ];
}
