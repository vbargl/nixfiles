{ lib, pkgs, config, ... }:
let
  hasConnectivityPurpose = builtins.elem "connectivity" config.purpose;

  pkgsSet = [
    pkgs.zerotierone
    pkgs.snx-rs

    # TODO: when https://github.com/NixOS/nixpkgs/pull/439308 gets merged
    # pkgs.nordvpn
  ];
in
{
  config = lib.mkIf hasConnectivityPurpose {
    home.packages = pkgsSet;
  };
}
