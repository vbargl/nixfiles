{ self, pkgs, ... }: {
  imports = [ self.homeModules.helix ];

  home.packages = with pkgs; [
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
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  nxf.home.helix.includeDevTooling = true;
}
