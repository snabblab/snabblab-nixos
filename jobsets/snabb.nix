{ pkgs ? (import <nixpkgs> {})
, snabbSrc ? (builtins.fetchTarball https://github.com/snabbco/snabb/tarball/next)
}:

with pkgs;
with lib;
with vmTools;

let
  # see https://github.com/snabbco/snabb/blob/master/src/doc/testing.md
  test_env = fetchurl {
    url = "http://lab1.snabb.co:2008/~max/assets/vm-ubuntu-trusty-14.04-dpdk-snabb.tar.gz";
    sha256 = "0323591i925jhd6wv8h268wc3ildjpa6j57n4p9yg9d6ikwkw06j";
  };
  optionalGetEnv = first: default: let
      maybeEnv = builtins.getEnv first;
    in if (maybeEnv != "") then maybeEnv else default;
in rec {
  manual = import "${snabbSrc}/src/doc" {};
  snabb = import "${snabbSrc}" {};
  tests = stdenv.mkDerivation rec {
    name = "snabb-tests";

    src = snabb.src;

    # allow sudo
    __noChroot = true;
    requiredSystemFeatures = [ "performance" ];

    buildInputs = [ git telnet tmux numactl bc iproute which qemu ];

    buildPhase = ''
      export PATH=$PATH:/var/setuid-wrappers/
      export HOME=$TMPDIR

      # make sure we reuse the snabb built in another derivation
      ln -s ${snabb}/bin/snabb src/snabb
      sed -i 's/testlog snabb/testlog/' src/Makefile

      # setup the environment
      mkdir ~/.test_env
      tar xvzf ${test_env} -C ~/.test_env/
    '';

    doCheck = true;
    checkPhase = ''
      export SNABB_PCI0=${ optionalGetEnv "SNABB_PCI0" "0000:01:00.0"}
      export SNABB_PCI_INTEL0=${ optionalGetEnv "SNABB_PCI_INTEL0" "0000:01:00.0"}
      export SNABB_PCI_INTEL1=${ optionalGetEnv "SNABB_PCI_INTEL1" "0000:01:00.1"}
      export FAIL_ON_FIRST=true

      # run tests
      sudo -E make test -C src/
    '';

    installPhase = ''
      mkdir -p $out/nix-support

      # keep the logs
      cp src/testlog/* $out/
      for f in $(ls $out/* | sort); do
        echo "file log $f"  >> $out/nix-support/hydra-build-products
      done
    '';
   };
  distro-builds = with diskImages; builtins.listToAttrs (map
    (diskImage: { inherit (diskImage) name; value = runInLinuxImage (snabb // { inherit diskImage; name = "${snabb.name}-${diskImage.name}";});})
    [ fedora23x86_64
      debian8x86_64
      ubuntu1510x86_64
      ubuntu1604x86_64
      centos65x86_64
    ]);
}
