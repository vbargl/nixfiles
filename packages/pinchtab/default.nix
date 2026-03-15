{ lib, stdenvNoCC, fetchurl }:

let
  version = "0.8.5";

  sources = {
    x86_64-linux = fetchurl {
      url = "https://github.com/pinchtab/pinchtab/releases/download/v${version}/pinchtab-linux-amd64";
      sha256 = "0jz35y686b2wgvdqqgljfm2jca757vsn3lg9a19s6vbhp4fh239l";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/pinchtab/pinchtab/releases/download/v${version}/pinchtab-linux-arm64";
      sha256 = "0fpm3rg8y2ysdl7lrimw2dqraydxz1qgn5n4wk1xvf6lvrid9lgh";
    };
  };
in

stdenvNoCC.mkDerivation {
  pname = "pinchtab";
  inherit version;

  src = sources.${stdenvNoCC.hostPlatform.system}
    or (throw "pinchtab: unsupported system ${stdenvNoCC.hostPlatform.system}");

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/pinchtab
    runHook postInstall
  '';

  meta = {
    description = "High-performance browser automation bridge and multi-instance orchestrator";
    homepage = "https://github.com/pinchtab/pinchtab";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "pinchtab";
  };
}
