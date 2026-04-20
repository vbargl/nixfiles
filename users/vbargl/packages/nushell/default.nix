{ pkgs, ... }:
{
  home.packages = [ pkgs.nushell ];

  xdg.configFile."nushell/env.nu".source = ./config/env.nu;
  xdg.configFile."nushell/config.nu".source = ./config/config.nu;
}
