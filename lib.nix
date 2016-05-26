{ pkgs ? import <nixpkgs> {}}:

with pkgs;

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
    murren = {};
  };

  getPCIVars = hardware:
    let
      pcis = PCIAssignments."${hardware}" or (throw "No such PCIAssignments server group as ${hardware}");
    in  pcis  // {
      requiredSystemFeatures = [ hardware ];
    };

  # Function for running commands in environment as Snabb expects tests to run
  mkSnabbTest = { name
                , snabb  # snabb derivation used
                , checkPhase # required phase for actually running the test
                , hardware  # on what set of hardware should we run this?
                , needsTestEnv ? false  # if true, copies over our testEnv
                , testEnv ? test_env
                , isDPDK ? false # if true, pass the kernel init for dpdk qemu
                , useNixTestEnv ? false # if true, copes over our test_env_nix
                , alwaysSucceed ? false # if true, the build will always succeed with a log
                , ...
                }@attrs:
    stdenv.mkDerivation ((getPCIVars hardware) // {
      src = snabb.src;

      buildInputs = [ git telnet tmux numactl bc iproute which qemu utillinux ];

      prePatch = ''
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
        cp --no-preserve=mode -r ${testEnv}/* ~/.test_env/
      '' + lib.optionalString useNixTestEnv ''
        mkdir ~/.test_env
        cp --no-preserve=mode -r ${test_env_nix}/* ~/.test_env/
      '';

      SNABB_KERNEL_PARAMS = lib.optionalString useNixTestEnv
        (if (isDPDK)
        then "init=${snabb_config_dpdk.system.build.toplevel}/init"
        else "init=${snabb_config.system.build.toplevel}/init");

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

   # Snabb fixtures

   # modules and NixOS config for plain qemu image
   snabb_modules = [
     <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
     ({config, pkgs, ...}: {
       environment.systemPackages = with pkgs; [ inetutils screen python pciutils ethtool tcpdump netcat iperf ];
       fileSystems."/".device = "/dev/disk/by-label/nixos";
       boot.loader.grub.device = "/dev/sda";

       # settings needed by tests
       boot.kernelPackages = pkgs.linuxPackages_4_1;
       networking.firewall.enable = lib.mkOverride 150 false;
       services.mingetty.autologinUser = "root";
       users.extraUsers.root.initialHashedPassword = lib.mkOverride 150 "";
       networking.usePredictableInterfaceNames = false;
     })
   ];
   snabb_config = (import <nixpkgs/nixos/lib/eval-config.nix> { modules = snabb_modules; }).config;

   # modules and NixOS config for dpdk qmemu image
   snabb_modules_dpdk = [
     ({config, pkgs, lib, ...}:
       let
         dpdk_bind = fetchurl {
           url = "https://raw.githubusercontent.com/scylladb/dpdk/8ea56fadc9a49c575bee6bb3892bc17dd9ec4ab6/tools/dpdk_nic_bind.py";
           sha256 = "0z8big9gh49q9kh0jjg1p9g5ywwvb130r3bmhhpbgx7blhk9zb7f";
         };
       in {
         systemd.services.dpdk = {
           wantedBy = [ "multi-user.target" ];
           after = [ "network.target" ];
           path = with pkgs; [ kmod python pciutils iproute utillinux ];
           script = ''
             mkdir -p /hugetlbfs
             mount -t hugetlbfs nodev /hugetlbfs
             echo 64 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages
             MODULE_DIR=/run/current-system/kernel-modules/lib/modules modprobe uio
             insmod ${config.boot.kernelPackages.dpdk}/kmod/igb_uio.ko
             python ${dpdk_bind} --bind=igb_uio 00:03.0
             ${config.boot.kernelPackages.dpdk.examples}/l2fwd/x86_64-native-linuxapp-gcc/l2fwd -c 0x1 -n1 -- -p 0x1
           '';
         };
       }
     )
   ];
   snabb_config_dpdk = (import <nixpkgs/nixos/lib/eval-config.nix> { modules = snabb_modules_dpdk ++ snabb_modules; }).config;

   qemu_img = lib.makeOverridable (import <nixpkgs/nixos/lib/make-disk-image.nix>) {
     inherit lib pkgs;
     config = snabb_config;
     partitioned = true;
     format = "qcow2";
     diskSize = 2 * 1024;
   };
   qemu_dpdk_img = qemu_img.override { config = snabb_config_dpdk; };

   # files needed for some tests
   test_env_nix = runCommand "test-env-nix" {} ''
     mkdir -p $out
     ln -s ${qemu_img}/nixos.qcow2 $out/qemu.img
     ln -s ${qemu_dpdk_img}/nixos.qcow2 $out/qemu-dpdk.img
     ln -s ${snabb_config.system.build.kernel}/bzImage $out/bzImage
     ln -s ${snabb_config.system.build.toplevel}/initrd $out/initrd
   '';
}
