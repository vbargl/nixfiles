{ inputs, ... }: { imports = builtins.attrValues (inputs.nixlite.import ./.); }
