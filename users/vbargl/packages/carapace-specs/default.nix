{ lib, stdenvNoCC }:

stdenvNoCC.mkDerivation {
  pname = "carapace-specs";
  version = "0.1.0";

  src = ./specs;

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/carapace/specs
    cp *.yaml $out/share/carapace/specs/
    runHook postInstall
  '';

  meta = {
    description = "Custom carapace completion specs for CLI tools";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
