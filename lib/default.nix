{ pkgs ? import <nixpkgs> {}}:

let
  benchmarks = import ./benchmarks.nix { pkgs = pkgs; };
  testing = import ./testing.nix { pkgs = pkgs; };
  software = import ./software.nix { pkgs = pkgs; };
in testing // benchmarks // software
