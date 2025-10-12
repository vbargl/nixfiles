{ pkgs, ... }: 
{
  home.packages = with pkgs; [
    zerotierone
		snx-rs
		# nordvpn (when added)
  ];
}