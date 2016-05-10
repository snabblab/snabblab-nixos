{ master ? (builtins.fetchTarball https://github.com/snabbco/snabb/tarball/master)
, next ? (builtins.fetchTarball https://github.com/snabbco/snabb/tarball/next)
# specify how many times is each benchmark ran
, numTimesRunBenchmark ? 20
# specify on what hardware will the benchmarks be ran
, requiredSystemFeatures ? [ "performance" ]
, SNABB_PCI0 ? "0000:01:00.0"
, SNABB_PCI_INTEL0 ? "0000:01:00.0"
, SNABB_PCI_INTEL1 ? "0000:01:00.1"
, pkgs ? (import <nixpkgs> {})}:

with pkgs;
with lib;
with (import ../lib.nix);

let
  snabbBenchTest = name: snabb: makeOverridable mkSnabbBenchTest {
    inherit name snabb requiredSystemFeatures SNABB_PCI0 SNABB_PCI_INTEL0 SNABB_PCI_INTEL1;
    times = numTimesRunBenchmark;
    checkPhase = ''
      echo "Running benchmark $numRepeat at $(date)"
      /var/setuid-wrappers/sudo ${snabb}/bin/snabb snabbmark basic1 100e6 &> $out/log.txt
    '';
  };

  benchmarks = flatten [
    (snabbBenchTest "master" (snabbswitch.overrideDerivation (super: { src = master; })))
    (snabbBenchTest "next" (snabbswitch.overrideDerivation (super: {src = next; })))
  ];

  benchmark-report = runCommand "snabb-performance-final-report" { preferLocalBuild = true; } ''
    mkdir -p $out/nix-support

    ${concatMapStringsSep "\n" (drv: "cat ${drv}/log.txt > $out/${drv.benchName}-${toString drv.numRepeat}.log") benchmarks}

    tar cfJ logs.tar.xz -C $out .

    for f in $out/*; do
      echo "file log $f" >> $out/nix-support/hydra-build-products
    done

    mv logs.tar.xz $out/
    echo "file tarball $out/logs.tar.xz" >> $out/nix-support/hydra-build-products
  '';
in {
 inherit benchmark-report;
} // (builtins.listToAttrs (map (attrs: nameValuePair attrs.name attrs) benchmarks))
