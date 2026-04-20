{ self, pkgs, ... }:
{
  imports = [ self.users.vbargl.packages.zen-browser ];

  home.packages = with pkgs; [
    ghostty
    walker
    firefox
    thunderbird
    peazip
  ];
}
