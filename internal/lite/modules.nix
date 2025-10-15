# lite.modules.nix
#
# Lightweight modular system with type-aware deep merging.
#
#  - lists      → concatenated
#  - attrsets   → deep-merged recursively
#  - primitives → resolved by priorities:
#       default (10) < normal (50, implicit) < force (100)
#    Conflicts at equal priority cause an error.
#
# Modules:
#   - Function: { self, inputs, ... }: { imports = [ … ]; ... }
#   - or plain attrset (constant module)
#
# imports can include:
#   - modules (functions or attrsets)
#   - paths: imported; if they yield a function, it's auto-applied with `inputs`
#
# Usage:
#   lite.modules.eval { region = "eu-west-1"; } [ rootModule ]
#
# Example module:
#   { self, inputs, lite }: {
#     imports = [ ./submodule.nix ];
#     app.name = "demo";
#     port = lite.modules.default 8080;
#   }
#
lite:
let
  #########################################################################
  # Config (with defaults)
  #########################################################################
  priorities = { default = 10; normal = 50; force = 100; } // (
    if lite ? config && lite.config ? priorities
    then lite.config.priorities
    else {}
  );

  #########################################################################
  # Fixed-point (compat if builtins.fix unavailable)
  #########################################################################
  fix = f: let result = f result; in result;

  #########################################################################
  # Priority-based value
  #########################################################################
  prioval = prio: v: { __type = "lite.modules.prioval"; __mergePriority = prio; __mergeValue = v; };
  isPrioval = v: builtins.isAttrs v && (v ? __mergePriority) && (v ? __mergeValue);
  prioOf  = v: if isPrioval v then v.__mergePriority else priorities.normal;

  default = v: prioval priorities.default v;
  force   = v: prioval priorities.force v;  

  isPrimitive = v:
    let t = builtins.typeOf v;
    in
      t == "bool"   ||
      t == "int"    ||
      t == "float"  ||
      t == "string" ||
      t == "path"   ||
      t == "null";

  #########################################################################
  # Unwrapping (for clean final outputs)
  #########################################################################
  unwrap  = v: if isPrioval v then v.__mergeValue else v;
  deepUnwrap = v:
    let u = (unwrap v);
    in if builtins.isFunction u then
            u
       else if builtins.isAttrs u then
         builtins.mapAttrs (_: deepUnwrap) u
       else if builtins.isList u then
         builtins.map deepUnwrap u
       else u;

  #########################################################################
  # Deep, type-respecting merge
  #########################################################################
  merge = a: b:
    let
      unwrapA = unwrap a;
      unwrapB = unwrap b;
      prioA = prioOf a;
      prioB = prioOf b;
      prio = if prioA > prioB then prioA else prioB;
    in
         if prioA > prioB then a
    else if prioA < prioB then b
    else 
      if builtins.isList unwrapA && builtins.isList unwrapB then
        prioval prio (unwrapA ++ unwrapB)

      else if builtins.isAttrs unwrapA && builtins.isAttrs unwrapB then
        let
          keys = builtins.attrNames (unwrapA // unwrapB);
          valueFor = k:
              if (unwrapA ? ${k}) && (unwrapB ? ${k}) then merge unwrapA.${k} unwrapB.${k}
              else if unwrapA ? ${k} then unwrapA.${k}
              else unwrapB.${k};
          
          mergeAttrs = builtins.listToAttrs (builtins.map (k: { name = k; value = valueFor k; }) keys);
        in prioval prio mergeAttrs

      else if (isPrimitive unwrapA) && (isPrimitive unwrapB) then
        if unwrapA == unwrapB then a
        else
          throw "lite.modules: conflicting primitive values with same priority (${"unwrapA"} vs ${"unwrapB"})"

      else
        throw "lite.modules: incompatible types (${builtins.typeOf unwrapA} vs ${builtins.typeOf unwrapB})";

  mergeAll = xs:
    if xs == [] then prioval priorities.normal {}
    else builtins.foldl' merge (builtins.head xs) (builtins.tail xs);

  #########################################################################
  # Module evaluation
  #########################################################################
  resolveDefinition = context: definition:
  (
    if builtins.isAttrs definition then
      {
        definitions = if definition ? imports then definition.imports else [];
        payload = builtins.removeAttrs definition [ "imports" ];
      }        
    else if builtins.isList definition then
      {
        definitions = definition;
        payload = {};
      }
    else if builtins.isFunction definition then
      {
        definitions = [ (definition context) ];
        payload = {};
      }
    else if builtins.isPath definition then
      {
        definitions =  [ (import definition) ];
        payload = {};
      }
    else
      throw "lite.modules: expected module definition (attrset/function/list/path), got ${builtins.typeOf definition}"
   );

  expand = context: definition:
    let
      module = resolveDefinition context definition;
      rest  = builtins.concatMap (expand context) module.definitions;
    in
    [ module.payload ] ++ rest;

  #########################################################################
  # Public API
  #########################################################################
  eval = inputs: definition:
    fix (self:
      let
        context  = { inherit self inputs ; };
        payloads = expand context definition;
        merged   = mergeAll payloads;
      in
        deepUnwrap merged
    );

  export = {
    inherit
      eval
      merge
      mergeAll
      prioval
      default
      force
      ;
  };

in
export
