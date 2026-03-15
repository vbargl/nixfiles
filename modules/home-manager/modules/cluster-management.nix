{ lib, pkgs, config, ... }:
let
  hasClusterManagement = builtins.elem "cluster-management" config.purpose;
in
{
  config = lib.mkIf hasClusterManagement {
    home.packages = with pkgs; [
      k9s
      kubectl
      age
    ];
  };
}
