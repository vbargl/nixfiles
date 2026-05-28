{ pkgs, ... }:
{
  home.packages = [ pkgs.fish ];
  programs.fish.enable = true;
  programs.fish.generateCompletions = false;
}
