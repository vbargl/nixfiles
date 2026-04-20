{ pkgs, ... }: {
  nxf.home.zen-browser.enable = true;

  home.packages = with pkgs; [
    ghostty
    walker
    firefox
    thunderbird
    peazip
  ];
}
