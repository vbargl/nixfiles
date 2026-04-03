{ lib, pkgs, config, options, inputs, self, ... }:
let
  hasCaelestia = options.programs ? caelestia;
in
{
  options.modules.caelestia = {
    disableGameModeOnBoot = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Disable Caelestia game mode on boot";
    };
  };

  config = lib.optionalAttrs (hasCaelestia && config.programs.caelestia.enable) {
    programs.caelestia.settings = {
      services.useFahrenheit = lib.mkDefault false;
      services.useTwelveHourClock = lib.mkDefault false;
      bar.status.showAudio = lib.mkDefault true;
      general.apps.explorer = lib.mkDefault [ "dolphin" ];
      general.apps.terminal = lib.mkDefault [ "ghostty" ];
      paths.wallpaperDir = lib.mkDefault "${self}/assets/wallpapers";
    };

    systemd.user.services.caelestia-disable-gamemode = lib.mkIf config.modules.caelestia.disableGameModeOnBoot {
      Unit = {
        Description = "Disable Caelestia game mode on boot";
        After = [ "caelestia.service" ];
        Requires = [ "caelestia.service" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = let
          caelestia = inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.default;
        in "${pkgs.writeShellScript "disable-gamemode" ''
          ${pkgs.coreutils}/bin/sleep 2
          ${caelestia}/bin/caelestia-shell ipc call gameMode disable
        ''}";
      };
      Install.WantedBy = [ "caelestia.service" ];
    };
  };
}
