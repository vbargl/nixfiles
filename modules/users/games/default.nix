{ pkgs, hasCapability, lib, ... }:
lib.mkIf (hasCapability "gui") {
  users.users.vbargl.packages = with pkgs; [
    steam
    moonlight-qt
  ];
}
