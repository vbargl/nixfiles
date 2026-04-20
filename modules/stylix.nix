{ inputs, ... }:
{
  flake.nixosModules.stylix =
    { self, pkgs, ... }:
    {
      imports = [ inputs.stylix.nixosModules.stylix ];

      stylix = {
        enable = true;
        enableReleaseChecks = false;

        base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";

        image = "${self}/users/vbargl/assets/wallpapers/wallpaper.jpg";

        fonts = {
          monospace = {
            package = pkgs.nerd-fonts.jetbrains-mono;
            name = "JetBrainsMono Nerd Font";
          };
          sansSerif = {
            package = pkgs.inter;
            name = "Inter";
          };
        };

        cursor = {
          package = pkgs.rose-pine-cursor;
          name = "BreezeX-RosePine-Linux";
          size = 24;
        };

        targets.gnome.enable = false;
      };
    };
}
