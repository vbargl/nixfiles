{ inputs, ... }:
{
  flake.modules = {
    machines = inputs.nixlite.import ../modules/nixos;
    users    = inputs.nixlite.import ../modules/home;
  };
  flake.profiles = {
    machines = inputs.nixlite.import ../profiles/machines;
    users    = inputs.nixlite.import ../profiles/users;
  };
}
