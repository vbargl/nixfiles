{ ... }:
{
  flake.overlays.winbox =
    final: prev:
    {
      winbox4 = prev.winbox4.overrideAttrs (finalAttrs: oldAttrs: {
        version = "4.1";

        src = final.fetchurl {
          name = "WinBox_Linux-${finalAttrs.version}.zip";
          url = "https://download.mikrotik.com/routeros/winbox/${finalAttrs.version}/WinBox_Linux.zip";
          hash = "sha256-KNNbZhwyH1thiTZUa37fZZMpJUntSpWEeI2t/zmlTY8=";
        };

        postFixup = (oldAttrs.postFixup or "") + ''
          substituteInPlace "$out/share/applications/winbox.desktop" \
            --replace-fail "Exec=WinBox" "Exec=$out/bin/WinBox"
        '';

        meta = oldAttrs.meta // {
          changelog = "https://download.mikrotik.com/routeros/winbox/${finalAttrs.version}/CHANGELOG";
        };
      });
    };
}
