{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nxf.home.helix;

  basePackages = with pkgs; [
    yaml-language-server
    taplo
    vscode-langservers-extracted
    prettier
    bash-language-server
    shellcheck
    shfmt
    fish-lsp
    nufmt
    nixd
    nixfmt-rfc-style
  ];

  devPackages = with pkgs; [
    go
    gopls
    gofumpt
    delve
    rust-analyzer
    rustfmt
    lldb
    typescript-language-server
    svelte-language-server
    jdt-language-server
    kotlin-language-server
    metals
    terraform-ls
    opentofu
  ];
in
{
  options.nxf.home.helix.includeDevTooling = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Install language servers and formatters used for development work.";
  };

  config = {
    home.sessionVariables = {
      EDITOR = "hx";
      VISUAL = "hx";
    };

    home.packages = builtins.concatLists [
      (with pkgs; [ helix ])
      basePackages
      (lib.optionals cfg.includeDevTooling devPackages)
    ];

    xdg.configFile."helix/config.toml".source = ./config/config.toml;
    xdg.configFile."helix/languages.toml".source = ./config/languages.toml;
  };
}
