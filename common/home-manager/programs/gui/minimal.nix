{ pkgs, ... }: 
{
  home.packages = with pkgs; [
		walker      # launcher
		firefox     # browser
		thunderbird # email
		peazip      # archive manager
		waybar		  # status bar
		mako		    # notification daemon
		spotify		  # music streaming
  ];
}
