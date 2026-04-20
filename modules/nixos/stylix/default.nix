# modules/nixos/stylix/default.nix — transitional form (Task 3).
# Task 4 rewraps as a flake-parts module and drops the mkIf guard
# (importing becomes the opt-in).
{ inputs, pkgs, lib, config, ... }: {
  imports = [ inputs.stylix.nixosModules.stylix ];

  config = lib.mkIf config.environment.capabilities.gui {
    stylix = {
      enable = true;
      enableReleaseChecks = false;

      base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";

      image = ../../../assets/wallpapers/wallpaper.jpg;

      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name    = "JetBrainsMono Nerd Font";
        };
        sansSerif = {
          package = pkgs.inter;
          name    = "Inter";
        };
      };

      cursor = {
        package = pkgs.rose-pine-cursor;
        name    = "BreezeX-RosePine-Linux";
        size    = 24;
      };

      targets.gnome.enable = false;
    };
  };
}
