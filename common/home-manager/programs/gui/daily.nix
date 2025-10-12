{ pkgs, ... }: 
{
  home.packages = with pkgs; [
    keepassxc # password manager 
    winbox4   # microtik manager
		rustdesk  # remote desktop manager 
  ];
}
