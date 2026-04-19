{ pkgs, ... }: {
  users.users.vbargl.packages = with pkgs; [ nushell ];
  environment.shells = [ pkgs.nushell ];

  hjem.users.vbargl.files = {
    ".config/nushell/env.nu".source    = ./config/env.nu;
    ".config/nushell/config.nu".source = ./config/config.nu;
  };
}
