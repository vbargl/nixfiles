{ lib, ... }:
let
  discoverModules = dir:
    let
      entries = builtins.readDir dir;
      nixFiles = lib.filterAttrs
        (name: type: type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix")
        entries;
      dirs = lib.filterAttrs
        (name: type: type == "directory")
        entries;
    in
    lib.mapAttrs'
      (name: _: lib.nameValuePair (lib.removeSuffix ".nix" name) (dir + "/${name}"))
      nixFiles
    //
    lib.mapAttrs
      (name: _: dir + "/${name}")
      dirs;
in
{
  flake.modules = {
    homeManager = discoverModules ../homes/modules;
    nixos       = discoverModules ../machines/modules;
  };
}
