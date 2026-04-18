{ pkgs, hasCapability, lib, ... }:
lib.mkIf (hasCapability "gui") {
  users.users.vbargl.packages = with pkgs; [ zen-browser ];

  hjem.users.vbargl.files.".config/mimeapps.list".source = ./config/mimeapps.list;
}
