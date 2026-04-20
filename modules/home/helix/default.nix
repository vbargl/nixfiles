{ lib, pkgs, config, ... }:
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
    terraform-ls
    opentofu
  ];
in
{
  options.nxf.home.helix = {
    enable = lib.mkEnableOption "helix editor";
    includeDevTooling = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install go/rust/ts/svelte/terraform language servers and formatters.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      EDITOR = "hx";
      VISUAL = "hx";
    };

    home.packages =
      [ pkgs.helix ]
      ++ basePackages
      ++ lib.optionals cfg.includeDevTooling devPackages;

    xdg.configFile."helix/config.toml".source    = ./config/config.toml;
    xdg.configFile."helix/languages.toml".source = ./config/languages.toml;
  };
}
