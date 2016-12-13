# Benchmark lwaftr, collect measurements in CSV and generate a report

# How many times each benchmark is repeated
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
# (hash is extracted using
# $ nix-prefetch-url https://patch-diff.githubusercontent.com/raw/snabbco/snabb/pull/969.patch)
# example: snabbPatches = [
#   "https://patch-diff.githubusercontent.com/raw/snabbco/snabb/pull/969.patch 0fcp1yzkjhgrm7rlq2lpcb71nnhih3cwa189b3f14xv2k5yrsbmh"
# ];
, snabbPatches ? []
# Which benchmarks to execute
# For possible values see keys in the bottom of lib/benchmarks.nix, e.g. [ "iperf-base" ]
, benchmarkNames ? [ "lwaftr" ]
# Name of reports to be generated
# For possible values see lib/reports/, e.g. "basic"
, reports ? [ "lwaftr" ]
# What qemu versions to benchmark on, for possible values see lib/benchmarks.nix
, qemuVersions ? []
# Additional dpdk version to benchmark on, specified using source and name
, qemuAsrc ? null
, qemuAname ? null
, duration ? "10"
, conf ? "icmp_on_fail.conf"
, ipv4PCap ? "ipv4-0550.pcap"
, ipv6PCap ? "ipv6-0550.pcap"
, lwaftrMode 
}:

let
  pkgs = import nixpkgs {};
  locaLib = import ../lib { inherit pkgs; };

  # Build all specified Snabb branches
  snabbs = pkgs.lib.filter (snabb: snabb != null) [
    (locaLib.buildNixSnabb snabbAsrc snabbAname)
    (locaLib.buildNixSnabb snabbBsrc snabbBname)
    (locaLib.buildNixSnabb snabbCsrc snabbCname)
    (locaLib.buildNixSnabb snabbDsrc snabbDname)
    (locaLib.buildNixSnabb snabbEsrc snabbEname)
    (locaLib.buildNixSnabb snabbFsrc snabbFname)
  ];

  customQemu = locaLib.buildQemuFromSrc qemuAname qemuAsrc false;
  subQemus = (locaLib.selectQemus qemuVersions) ++ (if qemuAsrc != null then [customQemu] else []);

  # Benchmarks using a matrix of software and a number of repeats
  benchmarks-list =
    if (benchmarkNames == [])
    then throw "'benchmarkNames' input list should contain at least one element of: ${pkgs.lib.concatStringsSep ", " (builtins.attrNames locaLib.benchmarks)}"
    else
      locaLib.mergeAttrsMap (qemu:
        locaLib.mergeAttrsMap (snabb:
          locaLib.selectBenchmarks benchmarkNames {
            inherit snabb qemu times duration conf ipv4PCap ipv6PCap; mode = lwaftrMode; }
        ) snabbs
      ) subQemus;

  csv = locaLib.mkBenchmarkCSV (builtins.attrValues benchmarks-list) "benchmark,mode,duration,snabb,conf,id,link,sequence,score,qemu,unit";
in {
  # All versions of software used in benchmarks
  software = locaLib.listDrvToAttrs (snabbs ++ subQemus);
  benchmarks = benchmarks-list;
  inherit csv;
  reports =
    if (reports == [])
    then throw "'reports' input list should contain at least one element of: ${pkgs.lib.concatStringsSep ", " locaLib.listReports}"
    else pkgs.lib.listToAttrs (map (reportName:
      { name = reportName;
        value = locaLib.mkBenchmarkReport "${csv}/bench.csv" (builtins.attrValues benchmarks-list) reportName;
      }) reports);
}
