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
, benchmarkNames ? [ "basic" "iperf-base" "iperf-filter" "iperf-ipsec" "iperf-l2tpv3" "iperf-l2tpv3-ipsec" "dpdk" ]
, reports ? []
, kernelVersions ? []
, dpdkVersions ? []
, qemuVersions ? []
}:

with (import nixpkgs {});
with (import ../lib { pkgs = (import nixpkgs {}); });

let
  # mkSnabbBenchTest defaults
  defaults = { times = numTimesRunBenchmark; };

  snabbs = lib.filter (snabb: snabb != null) [
    (buildNixSnabb snabbAsrc snabbAname)
    (buildNixSnabb snabbBsrc snabbBname)
    (buildNixSnabb snabbCsrc snabbCname)
    (buildNixSnabb snabbDsrc snabbDname)
    (buildNixSnabb snabbEsrc snabbEname)
    (buildNixSnabb snabbFsrc snabbFname)
  ];

  subKernelPackages = selectKernelPackages kernelVersions;
  subQemus = selectQemus qemuVersions;

  # benchmarks using a matrix of software and a number of repeats
  benchmarks-list =
    #(lib.flatten (map (kPackages:
    (lib.flatten (map (dpdk:
    (lib.flatten (map (qemu:
    (lib.flatten (map (snabb:
      (selectBenchmarks benchmarkNames { inherit snabb qemu dpdk defaults kPackages; }))
    snabbs)))
    subQemus)))
    # kernel is fixed to 3.18 otherwise matrix takes a long time to evaluate
    (selectDpdks dpdkVersions linuxPackages_3_18)));
    #subKernelPackages));
in rec {
  # all versions of software used in benchmarks
  software = listDrvToAttrs (lib.flatten [
    snabbs (map (selectDpdks dpdkVersions) linuxPackages_3_18) subQemus
  ]);
  benchmarks = listDrvToAttrs benchmarks-list;
  benchmark-csv = mkBenchmarkCSV benchmarks-list;
  benchmark-reports = lib.listToAttrs (map (reportName:
      { name = reportName;
        value = mkBenchmarkReport benchmark-csv benchmarks-list reportName;
      }) reports);
}
