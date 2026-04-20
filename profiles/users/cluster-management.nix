{ pkgs, ... }: {
  home.packages = with pkgs; [ k9s kubectl age deploy-rs ];
}
