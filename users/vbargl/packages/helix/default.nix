{
  pkgs,
  ...
}:
let
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
  config = {
    home.sessionVariables = {
      EDITOR = "hx";
      VISUAL = "hx";
    };

    home.packages = builtins.concatLists [
      (with pkgs; [ helix ])
      basePackages
      devPackages
    ];

    xdg.configFile."helix/config.toml".source = ./config/config.toml;
    xdg.configFile."helix/languages.toml".source = ./config/languages.toml;
  };
}
