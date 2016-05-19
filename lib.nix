with (import <nixpkgs> {});

rec {
  # see https://github.com/snabbco/snabb/blob/master/src/doc/testing.md
  test_env = fetchzip {
    url = "https://s3.eu-central-1.amazonaws.com/snabb/vm-ubuntu-trusty-14.04-dpdk-snabb.tar.gz";
    sha256 = "095m9f77pq770lzd5w46rzqqsgyrv8svkqpgmrd756gswb4gd3x2";
    stripRoot = false;
  };

  PCIAssignments = {
    lugano = {
      SNABB_PCI0 = "0000:01:00.0";
      SNABB_PCI_INTEL0 = "0000:01:00.0";
      SNABB_PCI_INTEL1 = "0000:01:00.1";
    };
  };

  getPCIVars = hardware:
    let
      pcis = PCIAssignments."${hardware}" or (throw "No such server group as ${hardware}");
    in  pcis  // {
      requiredSystemFeatures = [ hardware ];
    };

  # Function for running commands in environment as Snabb expects tests to run
  mkSnabbTest = { name
                , snabb  # snabb derivation used
                , checkPhase # required phase for actually running the test
                , hardware  # on what set of hardware should we run this?
                , needsTestEnv ? false  # if true, copies over our test env
                , alwaysSucceed ? false # if true, the build will always succeed with a log
                , ...
                }@attrs:
    stdenv.mkDerivation ((getPCIVars hardware) // {
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
        cp --no-preserve=mode -r ${test_env}/* ~/.test_env/
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

   # take a list of derivations and make an attribute set of out their names
  listDrvToAttrs = list: builtins.listToAttrs (map (attrs: lib.nameValuePair (lib.replaceChars ["."] [""] attrs.name) attrs) list);
}
