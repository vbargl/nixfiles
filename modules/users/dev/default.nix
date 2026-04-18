{ lib, pkgs, hasCapability, ... }: {
  users.users.vbargl.packages = with pkgs; lib.mkMerge [
    [
      jujutsu
      git
      git-credential-keepassxc
      lazygit
      nixd
      xvfb-run
      ngrok
      kind
      nodejs
      pinchtab
    ]
    (lib.mkIf (hasCapability "gui") [
      vscode
      code-cursor
      jetbrains.idea
      jetbrains.goland
      jetbrains.rider
      jetbrains.webstorm
      android-studio
      postman
      realvnc-vnc-viewer
      remmina
      google-chrome
      p11-kit
    ])
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
