{ pkgs ? (import <nixpkgs> {})
, snabbSrc ? (builtins.fetchTarball https://github.com/snabbco/snabb/tarball/next)
, hardware ? "lugano"
}:

with pkgs;
with lib;
with vmTools;

let
  snabblabLib = import ../lib.nix;
in rec {
  manual = import "${snabbSrc}/src/doc" {};
  snabb = import "${snabbSrc}" {};
  tests = snabblabLib.mkSnabbTest ({
    name = "snabb-tests";
    inherit hardware snabb;
    needsTestEnv = true;
    checkPhase = ''
      # run tests
      export FAIL_ON_FIRST=true
      sudo -E make test -C src/

      # keep the logs
      cp src/testlog/* $out/
    '';
  });
  distro-builds = with diskImages; builtins.listToAttrs (map
    (diskImage: { inherit (diskImage) name; value = runInLinuxImage (snabb // { inherit diskImage; name = "${snabb.name}-${diskImage.name}";});})
    [ fedora23x86_64
      debian8x86_64
      ubuntu1510x86_64
      ubuntu1604x86_64
      # See https://github.com/snabbco/snabb/pull/899
      # centos65x86_64
    ]);
}
