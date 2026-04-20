{ self, pkgs, ... }: {
  imports = [ self.homeModules.zen-browser ];

  home.packages = with pkgs; [
    ghostty
    walker
    firefox
    thunderbird
    peazip
  ];
}
