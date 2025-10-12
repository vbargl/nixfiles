{ pkgs, ... }: 
{
  home.packages = with pkgs; [
    steam     # gaming platform
    moonlight # streaming service for games
  ];
}