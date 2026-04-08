{ arc, ... }:
{
  arc.gaming.includes = [ arc.gaming._.discord ];

  arc.gaming._.discord = {
    darwin.homebrew.casks = [ "discord" ];
    nixos.homeManager.programs.discord.enable = true;
  };
}
