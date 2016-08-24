# Make a matrix benchmark out of Snabb + DPDK + QEMU + Linux (for iperf) combinations
# and generate a report based on the logs

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
# Additional qemu version to benchmark on, specified using source and name
, dpdkAsrc ? null
, dpdkAname ? null
# What qemu versions to benchmark on, for possible values see lib/benchmarks.nix
, qemuVersions ? []
# Additional dpdk version to benchmark on, specified using source and name
, qemuAsrc ? null
, qemuAname ? null
}:

with (import nixpkgs {});
with (import ../lib { pkgs = (import nixpkgs {}); });

let
  # Legacy naming
  times = numTimesRunBenchmark;

  # Build all specified Snabb branches
  snabbs = lib.filter (snabb: snabb != null) [
    (buildNixSnabb snabbAsrc snabbAname)
    (buildNixSnabb snabbBsrc snabbBname)
    (buildNixSnabb snabbCsrc snabbCname)
    (buildNixSnabb snabbDsrc snabbDname)
    (buildNixSnabb snabbEsrc snabbEname)
    (buildNixSnabb snabbFsrc snabbFname)
  ];

  customQemu = buildQemuFromSrc qemuAname qemuAsrc false;
  customDpdk = buildDpdkFromSrc dpdkAname dpdkAsrc;

  subKernelPackages = selectKernelPackages kernelVersions;
  subQemus = (selectQemus qemuVersions) ++ (if qemuAsrc != null then [customQemu] else []);

  # Benchmarks using a matrix of software and a number of repeats
  benchmarks-list = with lib;
    if (benchmarkNames == [])
    then throw "'benchmarkNames' input list should contain at least one element of: ${concatStringsSep ", " (builtins.attrNames benchmarks)}"
    else
    concatMap (kPackages:
      concatMap (dpdk:
        concatMap (qemu:
          concatMap (snabb:
            selectBenchmarks benchmarkNames { inherit snabb qemu dpdk times kPackages; }
          ) snabbs
        ) subQemus
      ) ((selectDpdks dpdkVersions kPackages) ++ (if dpdkAsrc != null then [(customDpdk kPackages)] else []))
    ) subKernelPackages;

in rec {
  # All versions of software used in benchmarks
  software = listDrvToAttrs (snabbs ++ subQemus ++ (selectDpdks dpdkVersions linuxPackages_3_18));
  benchmarks = listDrvToAttrs benchmarks-list;
  benchmark-csv = mkBenchmarkCSV benchmarks-list;
  benchmark-reports =
    if (reports == [])
    then throw "'reports' input list should contain at least one element of: ${lib.concatStringsSep ", " (listReports ../lib/reports)}"
    else lib.listToAttrs (map (reportName:
      { name = reportName;
        value = mkBenchmarkReport benchmark-csv benchmarks-list reportName;
      }) reports);
}
