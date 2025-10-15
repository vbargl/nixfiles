{
  description = "Lite modules";
  
  outputs = { ... }:
  let
    mkLite = config:
      let
        lite = {
          inherit config;
          modules   = import ./modules.nix lite;
          systems   = import ./systems.nix lite;
          configure = delta: mkLite (config // delta);
        };
      in lite;

  in
  mkLite {
    priorities = { default = 10; normal = 50; force = 100; };
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
  };
}
