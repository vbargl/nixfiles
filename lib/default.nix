{ inputs, ... }:
{
  flake.modules = {
    homeManager = inputs.nixlite.import ../homes/modules;
    nixos       = inputs.nixlite.import ../machines/modules;
  };
}
