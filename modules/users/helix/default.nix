{ lib, pkgs, config, hasCapability, ... }:
let
  home = config.users.users.vbargl.home;
  toml = pkgs.formats.toml {};

  configToml = toml.generate "helix-config.toml" {
    theme = "rose_pine_moon";
    keys.normal = {
      space.B = ":echo %sh{git blame -L %{cursor_line},+1 %{buffer_name}}";
      "A-r" = ":reload";
    };
  };

  languagesToml = toml.generate "helix-languages.toml" {
    language-server = {
      yaml-language-server = {
        command = "yaml-language-server";
        args = [ "--stdio" ];
      };
      taplo = {
        command = "taplo";
        args = [ "lsp" "stdio" ];
      };
      json-language-server = {
        command = "vscode-json-language-server";
        args = [ "--stdio" ];
        config.provideFormatter = true;
      };
      bash-language-server = {
        command = "bash-language-server";
        args = [ "start" ];
      };
      fish-lsp = {
        command = "fish-lsp";
        args = [ "start" ];
      };
      nu-lsp = {
        command = "nu";
        args = [ "--lsp" ];
      };
      nixd.command = "nixd";
    } // lib.optionalAttrs (hasCapability "dev") {
      gopls.command = "gopls";
      rust-analyzer.command = "rust-analyzer";
      jdtls = {
        command = "jdt-language-server";
        args = [
          "-configuration" "${home}/.cache/jdtls/config"
          "-data" "${home}/.cache/jdtls/workspace"
        ];
      };
      kotlin-language-server.command = "kotlin-language-server";
      metals.command = "metals";
      terraform-ls = {
        command = "terraform-ls";
        args = [ "serve" ];
      };
      typescript-language-server = {
        command = "typescript-language-server";
        args = [ "--stdio" ];
      };
      svelte-language-server = {
        command = "svelteserver";
        args = [ "--stdio" ];
      };
    };

    language = [
      { name = "yaml"; language-servers = [ "yaml-language-server" ]; auto-format = true; formatter = { command = "prettier"; args = [ "--parser" "yaml" ]; }; }
      { name = "toml"; language-servers = [ "taplo" ]; auto-format = true; formatter = { command = "taplo"; args = [ "fmt" "-" ]; }; }
      { name = "json"; language-servers = [ "json-language-server" ]; auto-format = true; formatter = { command = "prettier"; args = [ "--parser" "json" ]; }; }
      { name = "jsonc"; language-servers = [ "json-language-server" ]; auto-format = true; formatter = { command = "prettier"; args = [ "--parser" "json" ]; }; }

      { name = "bash"; language-servers = [ "bash-language-server" ]; auto-format = true; formatter = { command = "shfmt"; args = [ "-i" "2" "-" ]; }; }
      { name = "fish"; language-servers = [ "fish-lsp" ]; }
      { name = "nu"; language-servers = [ "nu-lsp" ]; auto-format = true; formatter = { command = "nufmt"; args = [ "--stdin" ]; }; }

      { name = "markdown"; formatter = { command = "prettier"; args = [ "--parser" "markdown" ]; }; }

      { name = "nix"; language-servers = [ "nixd" ]; auto-format = true; formatter = { command = "nixfmt"; }; }
    ] ++ lib.optionals (hasCapability "dev") [
      {
        name = "go";
        roots = [ "go.work" "go.mod" ];
        language-servers = [ "gopls" ];
        auto-format = true;
        formatter = { command = "gofumpt"; };
        comment-token = "//";
        debugger = {
          name = "go";
          transport = "tcp";
          command = "dlv";
          args = [ "dap" ];
          port-arg = "-l 127.0.0.1:{}";
          templates = [
            { name = "source"; request = "launch"; completion = [ { name = "entrypoint"; completion = "filename"; default = "."; } ]; args = { mode = "debug"; program = "{0}"; }; }
            { name = "binary"; request = "launch"; completion = [ { name = "binary"; completion = "filename"; } ]; args = { mode = "exec"; program = "{0}"; }; }
            { name = "test"; request = "launch"; completion = [ { name = "test"; completion = "filename"; default = "."; } ]; args = { mode = "test"; program = "{0}"; }; }
          ];
        };
      }
      { name = "gomod";  language-servers = [ "gopls" ]; }
      { name = "gowork"; language-servers = [ "gopls" ]; }
      { name = "gotmpl"; language-servers = [ "gopls" ]; }

      {
        name = "rust";
        language-servers = [ "rust-analyzer" ];
        auto-format = true;
        debugger = {
          name = "lldb-dap";
          transport = "stdio";
          command = "lldb-dap";
          templates = [
            { name = "binary"; request = "launch"; completion = [ { name = "binary"; completion = "filename"; } ]; args = { program = "{0}"; }; }
            { name = "binary (with args)"; request = "launch"; completion = [ { name = "binary"; completion = "filename"; } { name = "args"; } ]; args = { program = "{0}"; args = [ "{1}" ]; }; }
          ];
        };
      }

      { name = "typescript"; language-servers = [ "typescript-language-server" ]; auto-format = true; }
      { name = "tsx"; language-servers = [ "typescript-language-server" ]; auto-format = true; }
      { name = "javascript"; language-servers = [ "typescript-language-server" ]; auto-format = true; }
      { name = "jsx"; language-servers = [ "typescript-language-server" ]; auto-format = true; }

      { name = "svelte"; language-servers = [ "svelte-language-server" "typescript-language-server" ]; auto-format = true; }

      { name = "java";   language-servers = [ "jdtls" ]; }
      { name = "kotlin"; language-servers = [ "kotlin-language-server" ]; }
      { name = "scala";  language-servers = [ "metals" ]; }

      { name = "hcl"; language-servers = [ "terraform-ls" ]; auto-format = true; formatter = { command = "tofu"; args = [ "fmt" "-" ]; }; }
      { name = "tfvars"; language-servers = [ "terraform-ls" ]; auto-format = true; formatter = { command = "tofu"; args = [ "fmt" "-" ]; }; }
    ];
  };

  extraPackages = with pkgs; [
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
  ] ++ lib.optionals (hasCapability "dev") (with pkgs; [
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
  ]);
in
{
  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

  users.users.vbargl.packages = [ pkgs.helix ] ++ extraPackages;

  hjem.users.vbargl.files = {
    ".config/helix/config.toml".source = configToml;
    ".config/helix/languages.toml".source = languagesToml;
  };
}
