{ self, inputs, lib, ... }:
{
  flake.nixosModules.default = { lib, config, ... }: {
    imports =
      (lib.attrValues (inputs.nixlite.import ./modules/nixos))
      ++ (lib.attrValues (inputs.nixlite.import ./users));

    options.nxf = {
      profiles = lib.mkOption {
        type = lib.types.attrsOf (lib.types.attrsOf lib.types.deferredModule);
        readOnly = true;
        description = "Profiles exposed by this flake (machines and users).";
      };
    };

    config = {
      nxf.profiles = {
        machines = inputs.nixlite.import ./profiles/machines;
        users    = inputs.nixlite.import ./profiles/users;
      };
      home-manager.sharedModules =
        lib.attrValues (inputs.nixlite.import ./modules/home);
    };
  };
}
