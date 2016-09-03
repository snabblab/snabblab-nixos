# Build Snabb, Snabb manual and run tests for given Snabb branch

{ pkgs ? (import <nixpkgs> {})
# which Snabb source directory is used for testing
, snabbSrc ? (builtins.fetchTarball https://github.com/snabbco/snabb/tarball/next)
# what hardware group is used when executing the jobs
, hardware ? "lugano"
}:

let
  local_lib = import ../lib { inherit pkgs; };
in rec {
  manual = import "${snabbSrc}/src/doc" {};
  snabb = import "${snabbSrc}" {};
  tests = local_lib.mkSnabbTest {
    name = "snabb-tests";
    inherit hardware snabb;
    needsNixTestEnv = true;
    checkPhase = ''
      # run tests
      sudo -E make test -C src/ |& tee $out/tests.log

     if grep -q ERROR $out/tests.log; then
         touch $out/nix-support/failed
     else
         echo "All tests passed."
     fi

      # keep the logs
      cp src/testlog/* $out/
      cp src/qemu*.log $out/
    '';
  };
  distro-builds = with pkgs.vmTools.diskImages;
   pkgs.recurseIntoAttrs (builtins.listToAttrs (map
    (diskImage: {
       inherit (diskImage) name;
       value = pkgs.vmTools.runInLinuxImage (snabb // {
         inherit diskImage;
         name = "${snabb.name}-${diskImage.name}";
       });
    })
    # List of distros that are currently supported according to upstream EOL
    [
      # TODO: fedora22
      fedora23x86_64
      # https://github.com/snabblab/snabblab-nixos/pull/45
      # debian7x86_64
      debian8x86_64
      # https://github.com/snabblab/snabblab-nixos/pull/45
      # ubuntu1204x86_64
      ubuntu1404x86_64
      ubuntu1510x86_64
      ubuntu1604x86_64
      # https://en.opensuse.org/Lifetime
      opensuse132x86_64
      # https://wiki.centos.org/Download
      centos71x86_64
      # See https://github.com/snabbco/snabb/pull/899
      # centos65x86_64
  ]));
}
