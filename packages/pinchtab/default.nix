{
  perSystem =
    { pkgs, ... }:
    {
      packages.pinchtab = pkgs.callPackage ./package.nix { };
    };
}
