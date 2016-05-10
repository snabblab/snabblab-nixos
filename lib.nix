with (import <nixpkgs> {});

rec {
  # see https://github.com/snabbco/snabb/blob/master/src/doc/testing.md
  test_env = fetchurl {
    url = "http://lab1.snabb.co:2008/~max/assets/vm-ubuntu-trusty-14.04-dpdk-snabb.tar.gz";
    sha256 = "0323591i925jhd6wv8h268wc3ildjpa6j57n4p9yg9d6ikwkw06j";
  };
  mkSnabbTest = { snabb
                , checkPhase # required for actually running the test
                , SNABB_PCI0
                , SNABB_PCI_INTEL0
                , SNABB_PCI_INTEL1
                , requiredSystemFeatures ? [ "performance" ]
                }@attrs:
    stdenv.mkDerivation (rec {
      name = "snabb-test-env";

      src = snabb.src;

      # allow sudo in build
      __noChroot = true;

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

        mkdir $out
      '';

      doCheck = true;

      installPhase = ''
        for f in $(ls $out/* | sort); do
          mkdir -p $out/nix-support
          echo "file log $f"  >> $out/nix-support/hydra-build-products
        done
      '';
     } // attrs);
}
