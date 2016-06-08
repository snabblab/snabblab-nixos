{ pkgs ? import <nixpkgs> {}}:

with pkgs;

let
  benchmarks = import ./benchmarks.nix { pkgs = pkgs; };
  misc = import ./misc.nix { pkgs = pkgs; };
in misc // benchmarks

