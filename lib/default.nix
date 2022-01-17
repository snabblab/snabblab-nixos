{ pkgs ? import <nixpkgs> {}, nixpkgs ? <nixpkgs> }:

let
  benchmarks = import ./benchmarks.nix { pkgs = pkgs; nixpkgs = nixpkgs; };
  testing = import ./testing.nix { pkgs = pkgs; nixpkgs = nixpkgs; };
  software = import ./software.nix { pkgs = pkgs; nixpkgs = nixpkgs; };
in testing // benchmarks // software
