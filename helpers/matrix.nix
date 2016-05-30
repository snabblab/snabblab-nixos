 # Make a matrix benchmark out of Snabb + DPDK + QEMU + Linux (for iperf) combinations

  # specify how many times is each benchmark ran
{ numTimesRunBenchmark ? 1
, nixpkgs ? (fetchTarball https://github.com/NixOS/nixpkgs/archive/37e7e86ddd09d200bbdfd8ba8ec2fd2f0621b728.tar.gz)
}:

with (import nixpkgs {});
with (import ../lib.nix { pkgs = (import nixpkgs {}); });
with vmTools;

let
  # build functions for different software using overrides 

  buildSnabb = version: hash:
     snabbswitch.overrideDerivation (super: {
       name = "snabb-${version}";
       inherit version;
       src = fetchFromGitHub {
          owner = "snabbco";
          repo = "snabb";
          rev = "v${version}";
          sha256 = hash;
       };
     });
  buildQemu = version: hash:
     qemu.overrideDerivation (super: {
       name = "qemu-${version}";
       inherit version;
       src = fetchurl {
         url = "http://wiki.qemu.org/download/qemu-${version}.tar.bz2";
         sha256 = hash;
       };
       # TODO: fails on 2.6.0 and 2.3.1: https://hydra.snabb.co/eval/1181#tabs-still-fail
       #patches = super.patches ++ [ (pkgs.fetchurl {
       #  url = "https://github.com/SnabbCo/qemu/commit/f393aea2301734647fdf470724433f44702e3fb9.patch";
       #  sha256 = "0hpnfdk96rrdaaf6qr4m4pgv40dw7r53mg95f22axj7nsyr8d72x";
       #})];
     });

  buildDpdk = version: hash: kernel:
    let
      origDpdk = callPackage ../pkgs/dpdk.nix { kernel = kernel.kernel; };
      needsGCC49 = lib.any (v: v == version) ["1.7.1" "1.8.0" "2.0.0" "2.1.0"];
      dpdk = if needsGCC49
             then (origDpdk.override { stdenv = overrideCC stdenv gcc48;})
             else origDpdk;
    in dpdk.overrideDerivation (super: {
      name = "dpdk-${version}-${kernel.kernel.version}";
      inherit version;
      prePatch = ''
        find . -type f -exec sed -i 's/-Werror//' {} \;
      '';
      src = fetchurl {
        url = "http://dpdk.org/browse/dpdk/snapshot/dpdk-${version}.tar.gz";
        sha256 = hash;
      };
    });

  # define software stacks

  snabbs = [
    (buildSnabb "2016.03" "0wr54m0vr49l51pqj08z7xnm2i97x7183many1ra5bzzg5c5waky")
    (buildSnabb "2016.04" "1b5g477zy6cr5d9171xf8zrhhq6wxshg4cn78i5bki572q86kwlx")
    (buildSnabb "2016.05" "1xd926yplqqmgl196iq9lnzg3nnswhk1vkav4zhs4i1cav99ayh8")
  ];
  dpdks = kernel: map (x: x kernel) [
    (buildDpdk "16.04" "0yrz3nnhv65v2jzz726bjswkn8ffqc1sr699qypc9m78qrdljcfn")
    (buildDpdk "2.2.0" "03b1pliyx5psy3mkys8j1mk6y2x818j6wmjrdvpr7v0q6vcnl83p")
    (buildDpdk "2.1.0" "0h1lkalvcpn8drjldw50kipnf88ndv2wvflgkkyrmya5ga325czp")
    (buildDpdk "2.0.0" "0gzzzgmnl1yzv9vs3bbdfgw61ckiakgqq93b9pc4v92vpsiqjdv4")
    (buildDpdk "1.8.0" "0f8rvvp2y823ipnxszs9lh10iyiczkrhh172h98kb6fr1f1qclwz")
    (buildDpdk "1.7.1" "0yd60ww5xhf0dfl2x1pqx1m2363b2b7zp89mcya86j20gi3bgvlx")
  ];
  qemus = [
    # TODO: https://hydra.snabb.co/build/4596
    #(buildQemu "2.3.1" "0px1vhkglxzjdxkkqln98znv832n1sn79g5inh3aw72216c047b6")
    (buildQemu "2.4.1" "0xx1wc7lj5m3r2ab7f0axlfknszvbd8rlclpqz4jk48zid6czmg3")
    (buildQemu "2.5.1" "0b2xa8604absdmzpcyjs7fix19y5blqmgflnwjzsp1mp7g1m51q2")
    (buildQemu "2.6.0" "1v1lhhd6m59hqgmiz100g779rjq70pik5v4b3g936ci73djlmb69")
  ];
  kernels = [
    linuxPackages_3_14
    linuxPackages_3_18
    linuxPackages_4_1
    linuxPackages_4_3
    linuxPackages_4_4
  ];

  # mkSnabbBenchTest defaults
  defaults = {
    times = numTimesRunBenchmark;
    # TODO: eventually turn this on
    # alwaysSucceed = true;
    patches = [(fetchurl {
         url = "https://github.com/snabbco/snabb/commit/e78b8b2d567dc54cad5f2eb2bbb9aadc0e34b4c3.patch";
         sha256 = "1nwkj5n5hm2gg14dfmnn538jnkps10hlldav3bwrgqvf5i63srwl";
    })];
  };

  # functions for building benchmark executing

  mkMatrixBenchBasic = { snabb, ... }@attrs:
    mkSnabbBenchTest (defaults // {
      name = "${snabb.name}-basic1-100e6";
      hardware = "murren";
      inherit (attrs) snabb;
      checkPhase = ''
        /var/setuid-wrappers/sudo ${snabb}/bin/snabb snabbmark basic1 100e6 |& tee $out/log.txt
      '';
    });
  mkMatrixBenchNFV = { snabb, qemu, kernel, dpdk, ... }@attrs:
   mkSnabbBenchTest (defaults // {
      name = "${snabb.name}-${qemu.name}-${dpdk.name}-nfv";
      inherit (attrs) snabb qemu;
      testNixEnv = mkNixTestEnv { inherit kernel dpdk; };
      useNixTestEnv = true;
      hardware = "lugano";
      checkPhase = ''
        cd src
        /var/setuid-wrappers/sudo -E program/snabbnfv/selftest.sh bench |& tee $out/log.txt
      '';
   });
  mkMatrixBenchNFVPacketblaster = { snabb, qemu, kernel, dpdk, ... }@attrs:
    mkSnabbBenchTest (defaults // {
      name = "${snabb.name}-${qemu.name}-${dpdk.name}-nfv-dpdk64";
      inherit (attrs) snabb qemu;
      useNixTestEnv = true;
      testNixEnv = mkNixTestEnv { inherit kernel dpdk; };
      isDPDK = true;
      # TODO: get rid of this
      __useChroot = false;
      hardware = "lugano";
      checkPhase = ''
        cd src

        # TODO: for NICless run
        #export SNABB_PCI0=
        #export SNABB_PCI_INTEL0=
        #export SNABB_PCI_INTEL1=

        /var/setuid-wrappers/sudo -E timeout 160 program/snabbnfv/packetblaster_bench.sh |& tee $out/log.txt
      '';
    });
  mkMatrixBenchPacketblaster = { snabb, ... }@attrs:
    mkSnabbBenchTest (defaults // {
      name = "${snabb.name}-packetblaster-64";
      inherit (attrs) snabb;
      hardware = "lugano";
      checkPhase = ''
        cd src
        /var/setuid-wrappers/sudo ${snabb}/bin/snabb packetblaster replay --duration 1 \
          program/snabbnfv/test_fixtures/pcap/64.pcap "$SNABB_PCI_INTEL0" |& tee $out/log.txt
      '';
    });
  mkMatrixBenchPacketblasterSynth = { snabb, ... }@attrs:
    mkSnabbBenchTest (defaults // {
      name = "${snabb.name}-packetblaster-synth-64";
      inherit (attrs) snabb;
      hardware = "lugano";
      checkPhase = ''
        /var/setuid-wrappers/sudo ${snabb}/bin/snabb packetblaster synth \
          --src 11:11:11:11:11:11 --dst 22:22:22:22:22:22 --sizes 64 \
          --duration 1 "$SNABB_PCI_INTEL0" |& tee $out/log.txt
      '';
    });
in {
  # all versions of software used in benchmarks
  software = listDrvToAttrs (lib.flatten [
    snabbs qemus (map (k: dpdks k)  kernels)
  ]);
  # benchmarks using a matrix of software and a number of repeats
  benchmarks = listDrvToAttrs
    # TODO: should probably abstract this out, but for now it does the job
    (lib.flatten (map (kernel:
    (lib.flatten (map (dpdk:
    (lib.flatten (map (snabb:
    lib.flatten (map (qemu:
      let
        params = { inherit snabb qemu dpdk kernel; };
      in [
        (mkMatrixBenchBasic params)
        (mkMatrixBenchNFV params)
        (mkMatrixBenchNFVPacketblaster params)
        (mkMatrixBenchPacketblaster params)
        (mkMatrixBenchPacketblasterSynth params)
      ]
    ) qemus)) snabbs))) (dpdks kernel)))) kernels));
}
