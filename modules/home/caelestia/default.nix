{ inputs, ... }:
{
  flake.homeModules.caelestia = { lib, pkgs, config, ... }:
    let
      inherit (pkgs.stdenv.hostPlatform) system;
      cfg = config.nxf.home.caelestia;

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
      options.nxf.home.caelestia = {
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

      config = {
        home.packages = [ cfg.package ];

        xdg.configFile = lib.mkMerge [
          (lib.mkIf (shouldGenerate cfg) {
            "caelestia/shell.json".source = shellConfigFile;
          })
          (lib.mkIf (shouldGenerate cfg.cli) {
            "caelestia/cli.json".source = cliConfigFile;
          })
        ];

        systemd.user.services.caelestia = lib.mkIf cfg.systemd.enable {
          Unit = {
            Description = "Caelestia Shell Service";
            After       = [ cfg.systemd.target ];
            PartOf      = [ cfg.systemd.target ];
          };
          Install.WantedBy = [ cfg.systemd.target ];
          Service = {
            Type           = "exec";
            ExecStart      = "${cfg.package}/bin/caelestia-shell";
            Restart        = "on-failure";
            RestartSec     = "5s";
            TimeoutStopSec = "5s";
            Slice          = "session.slice";
            Environment = lib.mapAttrsToList (k: v: "${k}=${v}")
              ({ QT_QPA_PLATFORM = "wayland"; } // cfg.systemd.environment);
          };
        };

        systemd.user.services.caelestia-disable-gamemode = lib.mkIf cfg.disableGameModeOnBoot {
          Unit = {
            Description = "Disable Caelestia game mode on boot";
            After    = [ "caelestia.service" ];
            Requires = [ "caelestia.service" ];
          };
          Install.WantedBy = [ "caelestia.service" ];
          Service = {
            Type      = "oneshot";
            ExecStart = "${pkgs.writeShellScript "disable-gamemode" ''
              ${pkgs.coreutils}/bin/sleep 2
              ${cfg.package}/bin/caelestia-shell ipc call gameMode disable
            ''}";
          };
        };
      };
    };
}
