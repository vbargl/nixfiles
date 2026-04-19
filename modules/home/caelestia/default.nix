{ lib, pkgs, config, inputs, self, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) system;
  cfg = config.modules.caelestia;

  mkConfig = c:
    lib.pipe (if c.extraConfig != "" then c.extraConfig else "{}") [
      builtins.fromJSON
      (lib.recursiveUpdate c.settings)
      builtins.toJSON
    ];
  shouldGenerate = c: c.extraConfig != "" || c.settings != {};

  shellConfigFile = pkgs.writeText "caelestia-shell.json" (mkConfig cfg);
  cliConfigFile   = pkgs.writeText "caelestia-cli.json"   (mkConfig cfg.cli);
in
{
  options.modules.caelestia = {
    enable = lib.mkEnableOption "Caelestia shell";

    package = lib.mkOption {
      type    = lib.types.package;
      default = inputs.caelestia-shell.packages.${system}.with-cli;
      description = "Caelestia shell package (with-cli includes caelestia-shell + CLI)";
    };

    systemd = {
      enable = lib.mkOption {
        type    = lib.types.bool;
        default = true;
        description = "Enable the systemd user service for Caelestia shell";
      };
      target = lib.mkOption {
        type    = lib.types.str;
        default = "hyprland-session.target";
        description = "Systemd target that starts Caelestia";
      };
      environment = lib.mkOption {
        type    = lib.types.attrsOf lib.types.str;
        default = {};
        description = "Extra environment variables for the Caelestia systemd service";
      };
    };

    settings = lib.mkOption {
      type    = lib.types.attrsOf lib.types.anything;
      default = {};
      description = "Caelestia shell settings written to shell.json";
    };

    extraConfig = lib.mkOption {
      type    = lib.types.str;
      default = "";
      description = "Extra JSON merged into shell.json";
    };

    cli = {
      settings = lib.mkOption {
        type    = lib.types.attrsOf lib.types.anything;
        default = {};
        description = "Caelestia CLI settings written to cli.json";
      };
      extraConfig = lib.mkOption {
        type    = lib.types.str;
        default = "";
        description = "Extra JSON merged into cli.json";
      };
    };

    disableGameModeOnBoot = lib.mkOption {
      type    = lib.types.bool;
      default = true;
      description = "Disable Caelestia game mode on boot via a oneshot systemd service";
    };
  };

  config = lib.mkIf (cfg.enable && config.environment.capabilities.gui) {

    users.users.vbargl.packages = [ cfg.package ];

    hjem.users.vbargl.files = lib.mkMerge [
      (lib.mkIf (shouldGenerate cfg) {
        ".config/caelestia/shell.json".source = shellConfigFile;
      })
      (lib.mkIf (shouldGenerate cfg.cli) {
        ".config/caelestia/cli.json".source = cliConfigFile;
      })
    ];

    systemd.user.services.caelestia = lib.mkIf cfg.systemd.enable {
      description = "Caelestia Shell Service";
      after       = [ cfg.systemd.target ];
      partOf      = [ cfg.systemd.target ];
      wantedBy    = [ cfg.systemd.target ];
      unitConfig  = lib.mkIf (shouldGenerate cfg) {
        X-Restart-Triggers = "${shellConfigFile}";
      };
      environment = { QT_QPA_PLATFORM = "wayland"; } // cfg.systemd.environment;
      serviceConfig = {
        Type           = "exec";
        ExecStart      = "${cfg.package}/bin/caelestia-shell";
        Restart        = "on-failure";
        RestartSec     = "5s";
        TimeoutStopSec = "5s";
        Slice          = "session.slice";
      };
    };

    systemd.user.services.caelestia-disable-gamemode = lib.mkIf cfg.disableGameModeOnBoot {
      description = "Disable Caelestia game mode on boot";
      after       = [ "caelestia.service" ];
      requires    = [ "caelestia.service" ];
      wantedBy    = [ "caelestia.service" ];
      serviceConfig = {
        Type      = "oneshot";
        ExecStart = "${pkgs.writeShellScript "disable-gamemode" ''
          ${pkgs.coreutils}/bin/sleep 2
          ${cfg.package}/bin/caelestia-shell ipc call gameMode disable
        ''}";
      };
    };
  };
}
