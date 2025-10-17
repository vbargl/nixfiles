{ lib, pkgs, config, ... }:
let
  hasConnectivityPurpose = builtins.elem "connectivity" config.purpose;

  pkgsSet = with pkgs; [
    zerotierone
    snx-rs
    nordvpn
  ];
in
{
  config = lib.mkIf hasConnectivityPurpose {
    home.packages = pkgsSet;
  };
}
