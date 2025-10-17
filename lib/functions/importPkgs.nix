{ self, ... }:
{
  lib.importPkgs = nixpkgs: input: 
    import nixpkgs ({ config = self.config.nixpkgs; } // input);
}
