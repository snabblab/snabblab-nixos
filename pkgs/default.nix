{ pkgs ? (import <nixpkgs> {}) }:


let
  # let's define our own callPackage to avoid typing all dependencies
  callPackage = pkgs.lib.callPackageWith (pkgs // snabbpkgs);

  # our custom packages 
  snabbpkgs = rec {
    lock = pkgs.callPackage ./lock.nix {};
  };
in pkgs // {
  inherit snabbpkgs;
}
