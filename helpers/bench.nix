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
  defaults = {
    inherit requiredSystemFeatures SNABB_PCI0 SNABB_PCI_INTEL0 SNABB_PCI_INTEL1;
    times = numTimesRunBenchmark;
  };
  snabbBenchTestBasic = snabb: mkSnabbBenchTest (defaults // {
    inherit snabb;
    name = "${snabb.name}-basic1-100e6";
    checkPhase = ''
      /var/setuid-wrappers/sudo ${snabb}/bin/snabb snabbmark basic1 100e6 |& tee $out/log.txt
    '';
  });
  snabbBenchTestPacketblaster64 = snabb:  mkSnabbBenchTest (defaults // {
    inherit snabb;
    name = "${snabb.name}-packetblaster-64";
    checkPhase = ''
      cd src
      /var/setuid-wrappers/sudo ${snabb}/bin/snabb packetblaster replay --duration 1 \
        program/snabbnfv/test_fixtures/pcap/64.pcap "${SNABB_PCI_INTEL0}" |& tee $out/log.txt
    '';
  });
  snabbBenchTestPacketblasterSynth64 = snabb: mkSnabbBenchTest (defaults // {
    inherit snabb;
    name = "${snabb.name}-packetblaster-synth-64";
    checkPhase = ''
      /var/setuid-wrappers/sudo ${snabb}/bin/snabb packetblaster synth \
        --src 11:11:11:11:11:11 --dst 22:22:22:22:22:22 --sizes 64 \
        --duration 1 "${SNABB_PCI_INTEL0}" |& tee $out/log.txt
    '';
  });
  snabbBenchTestNFV = snabb: mkSnabbBenchTest (defaults // {
    inherit snabb;
    name = "${snabb.name}-nfv";
    needsTestEnv = true;
    checkPhase = ''
      cd src
      /var/setuid-wrappers/sudo -E program/snabbnfv/selftest.sh bench |& tee $out/log.txt
    '';
  });
  snabbBenchTestNFVJumbo = snabb: mkSnabbBenchTest (defaults // {
    inherit snabb;
    name = "${snabb.name}-nfv-jumbo";
    needsTestEnv = true;
    checkPhase = ''
      cd src
      /var/setuid-wrappers/sudo -E program/snabbnfv/selftest.sh bench jumbo |& tee $out/log.txt
    '';
  });
  snabbBenchTestNFVPacketblaster = snabb: mkSnabbBenchTest (defaults // {
    inherit snabb;
    name = "${snabb.name}-nfv-packetblaster";
    needsTestEnv = true;
    checkPhase = ''
      cd src
      /var/setuid-wrappers/sudo -E timeout 120 program/snabbnfv/packetblaster_bench.sh |& tee $out/log.txt
    '';
  });

  snabb_master = snabbswitch.overrideDerivation (super: { src = master; name = "snabb-master"; });
  snabb_next = snabbswitch.overrideDerivation (super: {src = next; name = "snabb-next"; });

  benchmarks = flatten [
    (snabbBenchTestBasic snabb_master)
    (snabbBenchTestBasic snabb_next)

    (snabbBenchTestPacketblaster64 snabb_master)
    (snabbBenchTestPacketblaster64 snabb_next)

    (snabbBenchTestPacketblasterSynth64 snabb_master)
    (snabbBenchTestPacketblasterSynth64 snabb_next)

    (snabbBenchTestNFV snabb_master)
    (snabbBenchTestNFV snabb_next)

    (snabbBenchTestNFVJumbo snabb_master)
    (snabbBenchTestNFVJumbo snabb_next)

    (snabbBenchTestNFVPacketblaster snabb_master)
    (snabbBenchTestNFVPacketblaster snabb_next)
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
