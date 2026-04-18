{ inputs, ... }:
{
  flake.modules = {
    homeManager = inputs.nixlite.import ../modules/users;
    nixos       = inputs.nixlite.import ../modules/machines;
  };
}
