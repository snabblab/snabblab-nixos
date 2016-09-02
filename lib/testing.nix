{ pkgs }:

rec {
  # Function to build test_env qemu images needed for some benchmarks
  mkNixTestEnv = import ./test_env.nix { pkgs = pkgs; };

  # Default PCCI assignment values for server groups
  PCIAssignments = {
    lugano = {
      SNABB_PCI0 = "0000:01:00.0";
      SNABB_PCI_INTEL0 = "0000:01:00.0";
      SNABB_PCI_INTEL1 = "0000:01:00.1";
    };
    murren = {};
  };

  # Given a server group name such as "lugano"
  # return attribute set of PCI assignment values
  getPCIVars = hardware:
    let
      pcis = PCIAssignments."${hardware}" or (throw "No such PCIAssignments group as ${hardware}");
    in  pcis  // {
      requiredSystemFeatures = [ hardware ];
    };

  # Function for running commands in environment as Snabb expects tests to run
  mkSnabbTest = { name # name of the test executed
                , snabb # snabb derivation used
                , qemu ? pkgs.qemu  # qemu package used in tests
                , checkPhase # bash (string) actually executing the test
                , hardware # on what server group should we run this?
                , needsNixTestEnv ? false # if true, copies over our test env
                , testNixEnv ? (mkNixTestEnv {}) # qemu images and kernel
                , alwaysSucceed ? false # if true, the build will succeed even on failure and provide a log
                , ...
                }@attrs:
    pkgs.stdenv.mkDerivation ((getPCIVars hardware) // {
      src = snabb.src;

      buildInputs = [ pkgs.git pkgs.telnet pkgs.tmux pkgs.numactl pkgs.bc pkgs.iproute pkgs.which pkgs.qemu pkgs.utillinux ];

      SNABB_KERNEL_PARAMS = pkgs.lib.optionalString needsNixTestEnv "init=/nix/var/nix/profiles/system/init";

      postUnpack = ''
        patchShebangs .
      '';

      buildPhase = ''
        export PATH=$PATH:/var/setuid-wrappers/
        export HOME=$TMPDIR

        # setup expected directories
        sudo mkdir -p /var/{run,tmp} /hugetlbfs
        sudo mount -t hugetlbfs none /hugetlbfs

        # make sure we reuse the snabb built in another derivation
        ln -s ${snabb}/bin/snabb src/snabb
        sed -i 's/testlog snabb/testlog/' src/Makefile

        mkdir -p $out/nix-support
      '' + pkgs.lib.optionalString needsNixTestEnv ''
        mkdir ~/.test_env
        cp --no-preserve=mode -r ${testNixEnv}/* ~/.test_env/
      '';

      doCheck = true;

      # http://unix.stackexchange.com/questions/14270/get-exit-status-of-process-thats-piped-to-another/73180#73180
      checkPhase =
        pkgs.lib.optionalString alwaysSucceed ''
          set +o pipefail
        '' + checkPhase +
        pkgs.lib.optionalString alwaysSucceed ''
          # if pipe failed, note that so it's eaiser to inspect end result
          [ "''${PIPESTATUS[0]}" -ne 0 ] && touch $out/nix-support/failed
          set -o pipefail
      '';

      # Adds all files as log types to build products
      installPhase = ''
        runHook preInstall

        for f in $(ls $out/* | sort); do
          if [ -f $f ]; then
            echo "file log $f"  >> $out/nix-support/hydra-build-products
          fi
        done

        runHook postInstall
      '';

     } // removeAttrs attrs [ "checkPhase" ]);

  # Take a list of derivations and make an attribute set using their name attribute as key
  listDrvToAttrs = list: builtins.listToAttrs (map (attrs: pkgs.lib.nameValuePair (versionToAttribute attrs.name) attrs) list);

  /* Merge a list of attributesets. It is assumed keys that collide have the same value.
  
     Example:
 
     mergeAttrs [{a = "foo";} {b = "bar";}]
     => { a = "foo"; b = "bar"; }

  */
  mergeAttrs = mergeAttrsMap pkgs.lib.constant;
  mergeAttrsMap = f: attrs: pkgs.lib.foldl (x: y: x // (f y)) {} attrs;

  /* Convert dots in the version to dashes.
     Reasoning: the version can be used as attribute key.
 
     Example:
   
     "blabla-1.2.3"
     => "blabla-1-2-3"
  */
  versionToAttribute = version: builtins.replaceStrings ["."] ["-"] version;
}
