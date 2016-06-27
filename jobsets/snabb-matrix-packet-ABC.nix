# Make a matrix benchmark out of Snabb + DPDK + QEMU + Linux (for iperf) combinations

# specify how many times is each benchmark ran
{ numTimesRunBenchmark ? 1
, nixpkgs ? (fetchTarball https://github.com/NixOS/nixpkgs/archive/37e7e86ddd09d200bbdfd8ba8ec2fd2f0621b728.tar.gz)
, snabbAsrc
, snabbBsrc ? null
, snabbCsrc ? null
, snabbDsrc ? null
, snabbEsrc ? null
, snabbFsrc ? null
, snabbAname
, snabbBname ? null
, snabbCname ? null
, snabbDname ? null
, snabbEname ? null
, snabbFname ? null
, benchmarkNames ? [ "basic" "iperf-base" "iperf-filter" "iperf-ipsec" "iperf-l2tpv3" "iperf-l2tpv3-ipsec" "dpdk"]
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
      patch -p1 < $testEnvPatch || true
    '';
  };

  snabbs = lib.filter (snabb: snabb != null) [
    (buildNixSnabb snabbAsrc snabbAname)
    (buildNixSnabb snabbBsrc snabbBname)
    (buildNixSnabb snabbCsrc snabbCname)
    (buildNixSnabb snabbDsrc snabbDname)
    (buildNixSnabb snabbEsrc snabbEname)
    (buildNixSnabb snabbFsrc snabbFname)
  ];

  # benchmarks using a matrix of software and a number of repeats
  benchmarks-list = (
    # l2fwd depends on snabb, qemu, dpdk and just uses the latest kernel
    (lib.flatten (map (dpdk:
    (lib.flatten (map (qemu:
    (lib.flatten (map (snabb:
      (selectBenchmarks
        benchmarkNames
        { inherit snabb qemu dpdk defaults; kernel = linuxPackages_3_18; }
      )
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
