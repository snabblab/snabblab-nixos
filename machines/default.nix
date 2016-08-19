with (import <nixpkgs> {});

let
  mapping = {
   build1 = "build-1";
   build2 = "build-2";
   build3 = "build-3";
   build4 = "build-4";
  };
  evalMachine = name:
    let
      modules = [
        (import ../machines/eiger.nix).${name}
        (import ../machines/eiger-production.nix).${name}
        { networking.hostName = mapping.${name}; }
      ];
    in {
      eval = import <nixpkgs/nixos/lib/eval-config.nix> { inherit modules; };
      config = {
        imports = modules;
      };
    };
  machines = ["build1" "build2" "build3" "build4"];
in stdenv.lib.genAttrs machines evalMachine
