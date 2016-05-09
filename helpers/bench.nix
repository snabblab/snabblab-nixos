{ master ? (builtins.fetchTarball https://github.com/snabbco/snabb/tarball/master)
, next ? (builtins.fetchTarball https://github.com/snabbco/snabb/tarball/next)
, numTimesRunBenchmark ? 20
, pkgs ? (import <nixpkgs> {})}:

with pkgs;
with lib;

let
  # buildNTimes: repeat building a derivation for n times
  # buildNTimes: Derivation -> Int -> [Derivation]
  buildNTimes = drv: n: map (i: overrideDerivation drv (attrs: { name = attrs.name + "-num-${toString i}"; numRepeat = i; })) (range 1 n);

  # runs the benchmark without chroot to be able to use pci device assigning
  mkBenchmarks = { name, snabb, command, times ? numTimesRunBenchmark }: buildNTimes (runCommand "benchmark-${snabb.name}" { benchName = name; requiredSystemFeatures = "performance"; __noChroot = true; } ''
    mkdir -p $out/nix-support
    echo "Running benchmark $numRepeat at $(date)"
    /var/setuid-wrappers/sudo ${command snabb} &> $out/log.txt
    echo "file log $out/log.txt" >> $out/nix-support/hydra-build-products
  '') times;

  command = snabb: "${snabb}/bin/snabb snabbmark basic1 100e6";
  benchmarks = flatten [
    (mkBenchmarks { name = "master"; snabb = snabbswitch.overrideDerivation (super: { src = master; }); inherit command;})
    (mkBenchmarks { name = "next"; snabb = snabbswitch.overrideDerivation (super: {src = next; }); inherit command;})
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
