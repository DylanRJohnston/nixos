{ arc, ... }:

{
  # arc.interactive.includes = [ arc.interactive._.sunset ];

  arc.interactive._.sunset.homeManager.services.wlsunset = {
    enable = true;
    latitude = "-31.0 ";
    longitude = "115.8";
    temperature = {
      day = 6500;
      night = 2700;
    };
  };
}
