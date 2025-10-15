{ lib, ... }:
let
  inherit (lib) types mkOption;

  environmentCapabilitiesSet = [
    "gui" # for machines that 
  ];

  purposeSet = [
    # Minimal subset of packages will be always included automatically
    # If machine.capabilities contains "gui", minimal subset of packages
    # for GUI environment will also be included

    "dev"          # for development,  see purpose/dev.nix
    "connectivity" # vpn capabilities, see purpose/connectivity.nix

    # These are only if machine.capabilities contains "gui",
    # as packages mentioned in this purpose-based configurations
    # are usually GUI apps.
    "games" # for gaming,           see purpose/gui/games.nix
    "media" # for watching media,   see purpose/gui/media.nix
    "daily" # some daily used apps, see purpose/gui/daily.nix
  ];
in
{
  options.environment.capabilities = mkOption {
    type = types.listOf (types.enum environmentCapabilitiesSet);
    default = [];
    description = "Define environment capabilities";
  };

  options.purpose = mkOption {
    type = types.listOf (types.enum purposeSet);
    default = [];
    description = "Define purpose of use for profile in current environment";
  };
}
