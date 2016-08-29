{ pkgs }:

# Functions for executing benchmarks on different hardware groups,
# collecting results by parsing logs and converting them to CSV and
# generating reports using Rmarkdown.

with pkgs;
with (import ./testing.nix { inherit pkgs; });
with (import ./software.nix { inherit pkgs; });

rec {
  /* Execute a benchmark named as specified using `name` parameter,
     repeated as many times as the integer `times`.

     `toCSV` function is mandatory. It's called using the resulting
     benchmark derivation and returns a bash snippet. The function
     should parse the log in ${drv}/log.txt and set `score` variable
     providing the benchmark value. It should then call `writeCSV`
     function to generate the CSV line.

     `meta` attribute includes information needed at CSV generation time.

     The rest of the attributes are specified in testing.nix:`mkSnabbTest`
  */
  mkSnabbBenchTest = { name, times, toCSV, ... }@attrs:
   let
     # patch needed for Snabb v2016.05 and lower
     testEnvPatch = fetchurl {
       url = "https://github.com/snabbco/snabb/commit/e78b8b2d567dc54cad5f2eb2bbb9aadc0e34b4c3.patch";
       sha256 = "1nwkj5n5hm2gg14dfmnn538jnkps10hlldav3bwrgqvf5i63srwl";
     };
     snabbBenchmark = num:
       let
         name' = "${name}_num=${toString num}";
       in {
         ${name'} = lib.hydraJob (mkSnabbTest ({
           name = name';
           alwaysSucceed = true;
           patchPhase = ''
             patch -p1 < ${testEnvPatch} || true
           '';
           preInstall = ''
             cp qemu*.log $out/ || true
             cp snabb*.log $out/ || true
           '';
           meta = {
             snabbVersion = attrs.snabb.version or "";
             qemuVersion = attrs.qemu.version or "";
             kernelVersion = attrs.kPackages.kernel.version or "";
             dpdkVersion = attrs.dpdk.version or "";
             repeatNum = num;
             inherit toCSV;
           } // (attrs.meta or {});
         } // removeAttrs attrs [ "times" "toCSV" "dpdk" "kPackages" "meta" "name"]));
       };
   in mergeAttrsMap snabbBenchmark (lib.range 1 times);

  /* Execute `basic1` benchmark.

     `basic1` has no dependencies except Snabb,
     being a minimal configuration for a benchmark.    
  */
  mkMatrixBenchBasic = { snabb, times, hardware ? "murren", ... }:
    mkSnabbBenchTest {
      name = "basic1_snabb=${versionToAttribute snabb.version or ""}_packets=100e6";
      inherit snabb times hardware;
      checkPhase = ''
        /var/setuid-wrappers/sudo ${snabb}/bin/snabb snabbmark basic1 100e6 |& tee $out/log.txt
      '';
      toCSV = drv: ''
        score=$(awk '/Mpps/ {print $(NF-1)}' < ${drv}/log.txt)
        ${writeCSV drv "basic" "Mpps"}
      '';
    };

  /* Execute `packetblaster` benchmark.

    `packetblaster` sets "lugano" as default hardware group,
    as the benchmark depends on having a NIC installed.
  */
  mkMatrixBenchPacketblaster = { snabb, times, hardware ? "lugano", ... }:
    mkSnabbBenchTest {
      name = "${versionToAttribute snabb.version or ""}-packetblaster-64";
      inherit snabb times hardware;
      toCSV = drv: ''
        pps=$(cat ${drv}/log.txt | grep TXDGPC | cut -f 3 | sed s/,//g)
        score=$(echo "scale=2; $pps / 1000000" | bc)
        ${writeCSV drv "blast" "Mpps"}
      '';
      checkPhase = ''
        cd src
        /var/setuid-wrappers/sudo ${snabb}/bin/snabb packetblaster replay --duration 1 \
          program/snabbnfv/test_fixtures/pcap/64.pcap "$SNABB_PCI_INTEL0" |& tee $out/log.txt
      '';
    };

  /* Execute `packetblaster-synth` benchmark.

    Similar to `packetblaster` benchmark, but use "synth"
    command with size 64.
  */
  mkMatrixBenchPacketblasterSynth = { snabb, times, ... }:
    mkSnabbBenchTest {
      name = "${versionToAttribute snabb.version or ""}-packetblaster-synth-64";
      inherit snabb times;
      hardware = "lugano";
      toCSV = drv: ''
        pps=$(cat ${drv}/log.txt | grep TXDGPC | cut -f 3 | sed s/,//g)
        score=$(echo "scale=2; $pps / 1000000" | bc)
        ${writeCSV drv "blastsynth" "Mpps"}
      '';
      checkPhase = ''
        /var/setuid-wrappers/sudo ${snabb}/bin/snabb packetblaster synth \
          --src 11:11:11:11:11:11 --dst 22:22:22:22:22:22 --sizes 64 \
          --duration 1 "$SNABB_PCI_INTEL0" |& tee $out/log.txt
      '';
    };


  /* Execute `iperf` benchmark.

     Requires `testNixEnv` built fixtures providing qemu images.

     If hardware group doesn't use have a NIC, ports can be specified.
  */
  mkMatrixBenchNFVIperf = { snabb, times, qemu, kPackages, conf ? "NA", hardware ? "lugano", testNixEnv, ... }:
    let
      iperfports = {
        base         = "program/snabbnfv/test_fixtures/nfvconfig/test_functions/same_vlan.ports";
        filter       = "program/snabbnfv/test_fixtures/nfvconfig/test_functions/filter.ports";
        ipsec        = "program/snabbnfv/test_fixtures/nfvconfig/test_functions/crypto.ports";
        l2tpv3       = "program/snabbnfv/test_fixtures/nfvconfig/test_functions/tunnel.ports";
        l2tpv3_ipsec = "program/snabbnfv/test_fixtures/nfvconfig/test_functions/crypto-tunnel.ports";
      };
    in mkSnabbBenchTest {
      name = "iperf_conf=${conf}_snabb=${versionToAttribute snabb.version or ""}_kernel=${versionToAttribute kPackages.kernel.version}_qemu=${versionToAttribute qemu.version}";
      inherit hardware kPackages snabb times qemu testNixEnv;
      toCSV = drv: ''
        score=$(awk '/^IPERF-/ { print $2 }' < ${drv}/log.txt)
        ${writeCSV drv "iperf" "Gbps"}
      '';
      meta = { inherit conf; };
      needsNixTestEnv = true;
      SNABB_IPERF_BENCH_CONF = iperfports.${conf} or "";
      checkPhase = ''
        cd src
        /var/setuid-wrappers/sudo -E program/snabbnfv/selftest.sh bench |& tee $out/log.txt
      '';
    };

  /* Execute `l2fwd/dpdk` benchmark.

     Requires `testNixEnv` built fixtures providing qemu images.

     If hardware group doesn't use have a NIC then conf and pktsize are required
  */
  mkMatrixBenchNFVDPDK = { snabb, qemu, kPackages, dpdk, hardware ? "lugano", times, pktsize ? "", conf ? "", testNixEnv, ... }:
    let
      dpdkports = {
        base  = "program/snabbnfv/test_fixtures/nfvconfig/test_functions/snabbnfv-bench.port";
        nomrg = "program/snabbnfv/test_fixtures/nfvconfig/test_functions/snabbnfv-bench-no-mrg_rxbuf.port";
        noind = "program/snabbnfv/test_fixtures/nfvconfig/test_functions/snabbnfv-bench-no-indirect_desc.port";
      };
    in
    # there is no reason to run this benchmark on multiple kernels
    # 3.18 kernel must be used for older dpdks
    if (lib.substring 0 4 (kPackages.kernel.version) != "3.18")
    then []
    else mkSnabbBenchTest rec {
      name = "l2fwd_pktsize=${pktsize}_conf=${conf}_snabb=${versionToAttribute snabb.version or ""}_dpdk=${versionToAttribute dpdk.version}_qemu=${versionToAttribute qemu.version}";
      inherit snabb qemu times hardware dpdk kPackages testNixEnv;
      needsNixTestEnv = true;
      toCSV = drv: ''
        score=$(awk '/^Rate\(Mpps\):/ { print $2 }' < ${drv}/log.txt)
        ${writeCSV drv "l2fwd" "Mpps"}
      '';
      meta = { inherit pktsize conf; };
      checkPhase = 
        if hardware == "murren"
        then ''
          cd src

          export SNABB_PACKET_SIZES=${pktsize}
          export SNABB_DPDK_BENCH_CONF=${dpdkports.${conf}}
          /var/setuid-wrappers/sudo -E timeout 120 program/snabbnfv/dpdk_bench.sh |& tee $out/log.txt
        '' else ''
          cd src
          /var/setuid-wrappers/sudo -E timeout 120 program/snabbnfv/packetblaster_bench.sh |& tee $out/log.txt
        '';
    };

  /* Given a benchmark derivation, benchmark name and a unit,
     write a line of the CSV file using all provided benchmark information.
  */
  writeCSV = drv: benchName: unit: ''
    if test -z "$score"; then score="NA"; fi
    echo ${benchName},${drv.meta.pktsize or "NA"},${drv.meta.conf or "NA"},${drv.meta.snabbVersion or "NA"},${drv.meta.kernelVersion or "NA"},${drv.meta.qemuVersion or "NA"},${drv.meta.dpdkVersion or "NA"},${toString drv.meta.repeatNum},$score,${unit} >> $out/bench.csv
  '';

  # Generate CSV out of collection of benchmarking logs
  mkBenchmarkCSV = benchmarkList:
   stdenv.mkDerivation {
     name = "snabb-report-csv";
     buildInputs = [ pkgs.gawk pkgs.bc ];
     # Build CSV on Hydra localhost to spare time on copying
     requiredSystemFeatures = [ "local" ];
     # TODO: uses writeText until following is merged https://github.com/NixOS/nixpkgs/pull/15803
     builder = writeText "csv-builder.sh" ''
       source $stdenv/setup
       mkdir -p $out/nix-support

       echo "benchmark,pktsize,config,snabb,kernel,qemu,dpdk,id,score,unit" > $out/bench.csv
       ${lib.concatMapStringsSep "\n" (drv: drv.meta.toCSV drv) benchmarkList}

       # Make CSV file available via Hydra
       echo "file CSV $out/bench.csv" >> $out/nix-support/hydra-build-products
     '';
    };

   /* Using a generated CSV file, list of benchmarks and a report name,
      generate a report using Rmarkdown.
   */
   mkBenchmarkReport = csv: benchmarksList: reportName:
    stdenv.mkDerivation {
      name = "snabb-report";
      buildInputs = [ rPackages.rmarkdown rPackages.ggplot2 rPackages.dplyr R pandoc which ];
      # Build reports on Hydra localhost to spare time on copying
      requiredSystemFeatures = [ "local" ];
      # TODO: use writeText until runCommand uses passAsFile (16.09)
      builder = writeText "csv-builder.sh" ''
        source $stdenv/setup

        # Store all logs
        mkdir -p $out/nix-support
        ${lib.concatMapStringsSep "\n" (drv: "cat ${drv}/log.txt > $out/${drv.name}-${toString drv.meta.repeatNum}.log") benchmarksList}
        tar cfJ logs.tar.xz -C $out .
        mv logs.tar.xz $out/
        echo "file tarball $out/logs.tar.xz" >> $out/nix-support/hydra-build-products

        # Create markdown report
        cp ${../lib/reports + "/${reportName}.Rmd"} ./report.Rmd
        cp ${csv} .
        cat bench.csv
        cat report.Rmd
        echo "library(rmarkdown); render('report.Rmd')" | R --no-save
        cp report.html $out
        echo "file HTML $out/report.html"  >> $out/nix-support/hydra-build-products
        echo "nix-build out $out" >> $out/nix-support/hydra-build-products
      '';
    };

   # Generate a list of names of available reports in `./lib/reports`
   listReports =
     map (name: lib.removeSuffix ".Rmd" name)
         (builtins.attrNames (builtins.readDir ../lib/reports));

   # Returns true if version is a prefix of drv.version
   matchesVersionPrefix = version: drv:
     lib.hasPrefix version (lib.getVersion drv);

   # Select software collections based on version strings
   selectQemus = versions:
     if versions == []
     then qemus
     else lib.concatMap (version: lib.filter (matchesVersionPrefix version) qemus) versions;
   selectDpdks = versions: kPackages:
     if versions == []
     then (dpdks kPackages)
     else lib.concatMap (version: lib.filter (matchesVersionPrefix version) (dpdks kPackages)) versions;
   selectKernelPackages = versions:
     if versions == []
     then kernelPackages
     else lib.concatMap (version: lib.filter (kPackages: lib.hasPrefix version (lib.getVersion kPackages.kernel)) kernelPackages) versions;

   # Given a list of names and benchmark inputs/parameters, get benchmarks by their alias and pass them the parameters
   selectBenchmarks = names: params:
     mergeAttrsMap (name: (lib.getAttr name benchmarks) params) names;

   # Benchmarks aliases that can be referenced using just a name, i.e. "iperf-filter"
   benchmarks = {
     basic = mkMatrixBenchBasic;

     packetblaster = mkMatrixBenchPacketblaster;
     packetblaster-synth = mkMatrixBenchPacketblasterSynth;

     iperf = mkMatrixBenchNFVIperf;
     iperf-base = params: mkMatrixBenchNFVIperf (params // {conf = "base"; hardware = "murren";});
     iperf-filter = params: mkMatrixBenchNFVIperf (params // {conf = "filter"; hardware = "murren";});
     iperf-ipsec = params: mkMatrixBenchNFVIperf (params // {conf = "ipsec"; hardware = "murren";});
     iperf-l2tpv3 = params: mkMatrixBenchNFVIperf (params // {conf = "l2tpv3"; hardware = "murren";});
     iperf-l2tpv3-ipsec = params: mkMatrixBenchNFVIperf (params // {conf = "l2tpv3_ipsec"; hardware = "murren";});

     dpdk = mkMatrixBenchNFVDPDK;
     dpdk-soft-base-256 = params: mkMatrixBenchNFVDPDK (params // {pktsize = "256"; conf = "base"; hardware = "murren";});
     dpdk-soft-nomrg-256 = params: mkMatrixBenchNFVDPDK (params // {pktsize = "256"; conf = "nomrg"; hardware = "murren";});
     dpdk-soft-noind-256 = params: mkMatrixBenchNFVDPDK (params // {pktsize = "256"; conf = "noind"; hardware = "murren";});
     dpdk-soft-base-64 = params: mkMatrixBenchNFVDPDK (params // {pktsize = "64"; conf = "base"; hardware = "murren";});
     dpdk-soft-nomrg-64 = params: mkMatrixBenchNFVDPDK (params // {pktsize = "64"; conf = "nomrg"; hardware = "murren";});
     dpdk-soft-noind-64 = params: mkMatrixBenchNFVDPDK (params // {pktsize = "64"; conf = "noind"; hardware = "murren";});
   };
}
