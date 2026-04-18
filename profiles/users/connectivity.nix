{ pkgs, ... }: {
  users.users.vbargl.packages = with pkgs; [
    zerotierone
    snx-rs
    nordvpn
  ];
}
