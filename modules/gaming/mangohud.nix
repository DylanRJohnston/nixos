{
  kit.gaming.nixos =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.mangohud ];

      homeManager.programs.mangohud = {
        enable = true;
        settings = {
          # --- POSITIONING ---
          position = "top-right"; # <--- This is the magic line
          horizontal = true; # Keeps it in a clean line instead of a block
          hud_no_margin = true; # Pulls it tight against the corner

          # --- VISUALS ---
          font_size = 24;
          background_alpha = "0.5";
          round_corners = 10;

          # --- STATS (Minimalist) ---
          fps = true;
          frametime = true;
          gpu_stats = true;
          gpu_temp = true;
          cpu_stats = true;
          cpu_temp = true;
          ram = true;
          vram = true;

          offset_x = 10;
          offset_y = 10;
        };
      };

      programs.steam.extraEnv = {
        MANGOHUD = "1";
        MANGOHUD_CONFIG = "read_cfg";
      };
    };
}
