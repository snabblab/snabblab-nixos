  # Make a matrix benchmark out of Snabb + DPDK + QEMU + Linux (for iperf) combinations

  # specify how many times is each benchmark ran
{ numTimesRunBenchmark ? 1
, nixpkgs ? (fetchTarball https://github.com/NixOS/nixpkgs/archive/37e7e86ddd09d200bbdfd8ba8ec2fd2f0621b728.tar.gz)
, snabb
, benchmarkNames ? [
    "basic" "iperf-base" "iperf-filter" "iperf-ipsec" "iperf-l2tpv3" "iperf-l2tpv3-ipsec"
    "dpdk-soft-base-256" "dpdk-soft-nomrg-256" "dpdk-soft-noind-256"
    "dpdk-soft-base-64" "dpdk-soft-nomrg-64" "dpdk-soft-noind-64"
  ]
}:

with (import nixpkgs {});
with (import ../lib { pkgs = (import nixpkgs {}); });
with vmTools;

let
  # mkSnabbBenchTest defaults
  defaults = {
    times = numTimesRunBenchmark;
    alwaysSucceed = true;
    patches = [(fetchurl {
         url = "https://github.com/snabbco/snabb/commit/e78b8b2d567dc54cad5f2eb2bbb9aadc0e34b4c3.patch";
         sha256 = "1nwkj5n5hm2gg14dfmnn538jnkps10hlldav3bwrgqvf5i63srwl";
    })];
  };

  snabbs = [(import snabb {})];

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
in rec {
  # all versions of software used in benchmarks
  software = listDrvToAttrs (lib.flatten [
    snabbs qemus (map (k: dpdks k)  kernels)
  ]);
  benchmarks = listDrvToAttrs benchmarks-list;
  benchmark-csv = mkBenchmarkCSV benchmarks-list;
  benchmark-report = mkBenchmarkReport benchmark-csv benchmarks-list "basic";
}
