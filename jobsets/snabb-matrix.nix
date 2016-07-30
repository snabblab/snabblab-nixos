# Make a matrix benchmark out of Snabb + DPDK + QEMU + Linux (for iperf) combinations
# and generate a report based on output

# Specify how many times each benchmark is repeated
{ numTimesRunBenchmark ? 1
# Collection of packages used
, nixpkgs ? (fetchTarball https://github.com/NixOS/nixpkgs/archive/37e7e86ddd09d200bbdfd8ba8ec2fd2f0621b728.tar.gz)
# Up to 6 different Snabb branches specified using source and name
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
# snabbPatches is a list of patches to be applied to all snabb versions
# (hash is extracted using $ nix-prefetch-url https://patch-diff.githubusercontent.com/raw/snabbco/snabb/pull/969.patch)
# example: snabbPatches = [ "https://patch-diff.githubusercontent.com/raw/snabbco/snabb/pull/969.patch 0fcp1yzkjhgrm7rlq2lpcb71nnhih3cwa189b3f14xv2k5yrsbmh"];
, snabbPatches ? []
# Which benchmarks to execute
# For possible values see keys in the bottom of lib/benchmarks.nix, e.g. [ "iperf-base" ]
, benchmarkNames ? [ ]
# Name of reports to be generated
# For possible values see lib/reports/, e.g. "basic"
, reports ? []
# What kernel versions to benchmark on, for possible values see lib/benchmarks.nix
, kernelVersions ? ["3.18"]  # fix kernel for now to reduce memory usage
# What dpdk versions to benchmark on, for possible values see lib/benchmarks.nix
, dpdkVersions ? []
# What qemu versions to benchmark on, for possible values see lib/benchmarks.nix
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
  benchmarks-list = with lib; flatten (
    concatMap (kPackages:
      concatMap (dpdk:
        concatMap (qemu:
          concatMap (snabb:
            selectBenchmarks benchmarkNames { inherit snabb qemu dpdk defaults kPackages; }
          ) snabbs
        ) subQemus
      ) (selectDpdks dpdkVersions kPackages)
    ) subKernelPackages);

in rec {
  # all versions of software used in benchmarks
  software = listDrvToAttrs (lib.flatten [
    snabbs (map (selectDpdks dpdkVersions) subKernelPackages) subQemus
  ]);
  benchmarks = listDrvToAttrs benchmarks-list;
  benchmark-csv = mkBenchmarkCSV benchmarks-list;
  benchmark-reports = lib.listToAttrs (map (reportName:
      { name = reportName;
        value = mkBenchmarkReport benchmark-csv benchmarks-list reportName;
      }) reports);
}
