# Benchmark lwaftr, collect measurements in CSV and generate a report

# Specify how many times each benchmark is repeated
{ times ? 1
# Collection of Nix packages used
, nixpkgs ? (fetchTarball https://github.com/NixOS/nixpkgs/archive/37e7e86ddd09d200bbdfd8ba8ec2fd2f0621b728.tar.gz)
# Up to 6 different Snabb branches specified using source and name
, snabbAsrc
, snabbAname
, snabbBsrc ? null
, snabbBname ? null
, snabbCsrc ? null
, snabbCname ? null
, snabbDsrc ? null
, snabbDname ? null
, snabbEsrc ? null
, snabbEname ? null
, snabbFsrc ? null
, snabbFname ? null
# snabbPatches is a list of patches to be applied to all snabb versions
# (hash is extracted using $ nix-prefetch-url https://patch-diff.githubusercontent.com/raw/snabbco/snabb/pull/969.patch)
# example: snabbPatches = [ "https://patch-diff.githubusercontent.com/raw/snabbco/snabb/pull/969.patch 0fcp1yzkjhgrm7rlq2lpcb71nnhih3cwa189b3f14xv2k5yrsbmh"];
, snabbPatches ? []
# Which benchmarks to execute
# For possible values see keys in the bottom of lib/benchmarks.nix, e.g. [ "iperf-base" ]
, benchmarkNames ? [ "lwaftr" ]
# Name of reports to be generated
# For possible values see lib/reports/, e.g. "basic"
, reports ? [ "basic" ]
# What qemu versions to benchmark on, for possible values see lib/benchmarks.nix
, qemuVersions ? []
# Additional dpdk version to benchmark on, specified using source and name
, qemuAsrc ? null
, qemuAname ? null
, lwaftrMode 
}:

with (import nixpkgs {});
with (import ../lib { pkgs = (import nixpkgs {}); });

let
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
  subQemus = (selectQemus qemuVersions) ++ (if qemuAsrc != null then [customQemu] else []);

  # Benchmarks using a matrix of software and a number of repeats
  benchmarks-list = with lib;
    if (benchmarkNames == [])
    then throw "'benchmarkNames' input list should contain at least one element of: ${concatStringsSep ", " (builtins.attrNames benchmarks)}"
    else
      mergeAttrsMap (qemu:
        mergeAttrsMap (snabb:
          selectBenchmarks benchmarkNames { inherit snabb qemu times; mode = lwaftrMode; }
        ) snabbs
      ) subQemus;

  csv = mkBenchmarkCSV (builtins.attrValues benchmarks-list);
in {
  # All versions of software used in benchmarks
  software = listDrvToAttrs (snabbs ++ subQemus);
  benchmarks = benchmarks-list;
  inherit csv;
  reports =
    if (reports == [])
    then throw "'reports' input list should contain at least one element of: ${lib.concatStringsSep ", " listReports}"
    else lib.listToAttrs (map (reportName:
      { name = reportName;
        value = mkBenchmarkReport "${csv}/bench.csv" (builtins.attrValues benchmarks-list) reportName;
      }) reports);
}
