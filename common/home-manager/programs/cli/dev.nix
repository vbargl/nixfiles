{ pkgs, ... }: 
{
  programs = {
    # enable with update to 25.11
    # jjui = {
    #   enable = true;
    # };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  home.packages = with pkgs; [
    jujutsu
    git
    lazygit
    nixd
  ];
}