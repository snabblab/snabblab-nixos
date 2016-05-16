with (import <nixpkgs> {});

rec {
  # see https://github.com/snabbco/snabb/blob/master/src/doc/testing.md
  test_env = fetchurl {
    url = "http://lab1.snabb.co:2008/~max/assets/vm-ubuntu-trusty-14.04-dpdk-snabb.tar.gz";
    sha256 = "0323591i925jhd6wv8h268wc3ildjpa6j57n4p9yg9d6ikwkw06j";
  };
  # Function for running commands in environment as Snabb expects tests to run
  mkSnabbTest = { name
                , snabb  # snabb derivation used
                , checkPhase # required phase for actually running the test
                , SNABB_PCI0
                , SNABB_PCI_INTEL0
                , SNABB_PCI_INTEL1
                , requiredSystemFeatures ? [ "performance" ]
                , needsTestEnv ? false  # if true, copies over our test env
                , alwaysSucceed ? false # if true, the build will always succeed with a log
                , ...
                }@attrs:
    stdenv.mkDerivation ({
      src = snabb.src;

      buildInputs = [ git telnet tmux numactl bc iproute which qemu utillinux ];

      patchPhase = ''
        patchShebangs src
      '';

      buildPhase = ''
        export PATH=$PATH:/var/setuid-wrappers/
        export HOME=$TMPDIR

        # setup expected directories
        sudo mkdir -p /var/run /hugetlbfs
        sudo mount -t hugetlbfs none /hugetlbfs

        # make sure we reuse the snabb built in another derivation
        ln -s ${snabb}/bin/snabb src/snabb
        sed -i 's/testlog snabb/testlog/' src/Makefile

        mkdir -p $out/nix-support
      '' + lib.optionalString needsTestEnv ''
        mkdir ~/.test_env
        tar xvzf ${test_env} -C ~/.test_env/
      '';

      doCheck = true;

      # http://unix.stackexchange.com/questions/14270/get-exit-status-of-process-thats-piped-to-another/73180#73180
      checkPhase = 
        lib.optionalString alwaysSucceed ''
          set +o pipefail
        '' + ''${checkPhase}'' +
        lib.optionalString alwaysSucceed ''
          # if pipe failed, note that so it's eaiser to inspect end result
          [ "''${PIPESTATUS[0]}" -ne 0 ] && touch $out/nix-support/failed
          set -o pipefail
      '';

      installPhase = ''
        for f in $(ls $out/* | sort); do
          if [ -f $f ]; then
            echo "file log $f"  >> $out/nix-support/hydra-build-products
          fi
        done
      '';
     } // removeAttrs attrs [ "checkPhase" ]);
  # buildNTimes: repeat building a derivation for n times
  # buildNTimes: Derivation -> Int -> [Derivation]
  buildNTimes = drv: n:
    let
      repeatDrv = i: lib.overrideDerivation drv (attrs: {
        name = attrs.name + "-num-${toString i}";
        numRepeat = i;
      });
    in map repeatDrv (lib.range 1 n);

  # runs the benchmark without chroot to be able to use pci device assigning
  mkSnabbBenchTest = { name, times, ... }@attrs:
   let
     snabbTest = mkSnabbTest ({
       name = "snabb-benchmark-${name}";
       benchName = name;
     } // removeAttrs attrs [ "times" ]);
   in buildNTimes snabbTest times;
}
