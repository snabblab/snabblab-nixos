# Make a matrix benchmark out of Snabb + DPDK + QEMU + Linux (for iperf) combinations

# specify how many times is each benchmark ran
{ numTimesRunBenchmark ? 1
, nixpkgs ? (fetchTarball https://github.com/NixOS/nixpkgs/archive/37e7e86ddd09d200bbdfd8ba8ec2fd2f0621b728.tar.gz)
, snabbMaster
, snabbNext
, snabbPacketA
, snabbPacketB
, snabbPacketC
}:

with (import nixpkgs {});
with (import ../lib { pkgs = (import nixpkgs {}); });
with vmTools;

let
  # mkSnabbBenchTest defaults
  defaults = {
    times = numTimesRunBenchmark;
    alwaysSucceed = true;
    testEnvPatch = [(fetchurl {
         url = "https://github.com/snabbco/snabb/commit/e78b8b2d567dc54cad5f2eb2bbb9aadc0e34b4c3.patch";
         sha256 = "1nwkj5n5hm2gg14dfmnn538jnkps10hlldav3bwrgqvf5i63srwl";
    })];
    patchPhase = '' 
      patch -t -p1 < $testEnvPatch
    '';
  };

  buildNixSnabb = snabb: version:
    (callPackage snabb {}).overrideDerivation (super:
      {
        name = super.name + version;
      }
    );
  snabbs = [
    (buildNixSnabb snabbMaster "master")
    (buildNixSnabb snabbNext "next")
    (buildNixSnabb snabbPacketA "packetA")
    (buildNixSnabb snabbPacketB "packetB")
    (buildNixSnabb snabbPacketC "packetC")
  ];

  # benchmarks using a matrix of software and a number of repeats
  benchmarks-list = (
    # l2fwd depends on snabb, qemu, dpdk and just uses the latest kernel
    (lib.flatten (map (dpdk:
    (lib.flatten (map (qemu:
    (lib.flatten (map (snabb:
      let
        params = { inherit snabb qemu dpdk defaults; kernel = linuxPackages_4_4; };
      in [
        (mkMatrixBenchBasic params)
        (mkMatrixBenchNFVIperf (params // {mtu = "1500"; conf = "base";}))
        (mkMatrixBenchNFVIperf (params // {mtu = "9000"; conf = "base";}))
        (mkMatrixBenchNFVIperf (params // {mtu = "1500"; conf = "filter";}))
        (mkMatrixBenchNFVIperf (params // {mtu = "1500"; conf = "ipsec";}))
        (mkMatrixBenchNFVIperf (params // {mtu = "1500"; conf = "l2tpv3";}))
        (mkMatrixBenchNFVIperf (params // {mtu = "1500"; conf = "l2tpv3_ipsec";}))
        (mkMatrixBenchNFVDPDK (params // {pktsize = "256"; conf = "base";}))
        (mkMatrixBenchNFVDPDK (params // {pktsize = "256"; conf = "nomrg";}))
        (mkMatrixBenchNFVDPDK (params // {pktsize = "256"; conf = "noind";}))
        (mkMatrixBenchNFVDPDK (params // {pktsize = "64"; conf = "base";}))
        (mkMatrixBenchNFVDPDK (params // {pktsize = "64"; conf = "nomrg";}))
        (mkMatrixBenchNFVDPDK (params // {pktsize = "64"; conf = "noind";}))
      ]
    ) snabbs))) qemus))) (dpdks linuxPackages_3_18)))
  );
in {
  # all versions of software used in benchmarks
  software = listDrvToAttrs (lib.flatten [
    snabbs qemus (map (k: dpdks k)  kernels)
  ]);
  benchmarks = listDrvToAttrs benchmarks-list;
  benchmark-csv = mkBenchmarkCSV benchmarks-list;
}
