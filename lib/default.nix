{ inputs, ... }:
{
  flake.modules = {
    machines = inputs.nixlite.import ../modules/machines;
    users    = inputs.nixlite.import ../modules/users;
  };
  flake.profiles = {
    machines = inputs.nixlite.import ../profiles/machines;
    users    = inputs.nixlite.import ../profiles/users;
  };
}
