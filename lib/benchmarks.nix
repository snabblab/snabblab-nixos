{ pkgs }:

# Functions for building different versions of software and running benchmarks

with pkgs;
with (import ./testing.nix { inherit pkgs; });

rec {
  buildSnabb = version: hash:
     snabbswitch.overrideDerivation (super: {
       name = "snabb-${version}";
       inherit version;
       src = fetchFromGitHub {
          owner = "snabbco";
          repo = "snabb";
          rev = "v${version}";
          sha256 = hash;
        };
     });

 buildNixSnabb = snabbSrc: version:
   if snabbSrc == null
   then null
   else
     (callPackage snabbSrc {}).overrideDerivation (super:
       {
         name = super.name + version;
         inherit version;
       }
     );

  buildQemu = version: hash: applySnabbPatch:
     let
       snabbPatch = pkgs.fetchurl {
         url = "https://github.com/SnabbCo/qemu/commit/f393aea2301734647fdf470724433f44702e3fb9.patch";
         sha256 = "0hpnfdk96rrdaaf6qr4m4pgv40dw7r53mg95f22axj7nsyr8d72x";
         name = "snabb-patch";
       };
     in qemu.overrideDerivation (super: {
       name = "qemu-${version}" + lib.optionalString applySnabbPatch "-with-snabbpatch";
       version = version + lib.optionalString applySnabbPatch "-with-snabbpatch";
       src = fetchurl {
         url = "http://wiki.qemu.org/download/qemu-${version}.tar.bz2";
         sha256 = hash;
       };
       patchPhase = ''
         substituteInPlace Makefile --replace \
           "install-datadir install-localstatedir" \
           "install-datadir" \
           --replace "install-sysconfig " ""
       '' + lib.optionalString applySnabbPatch ''
         patch -p1 < ${snabbPatch}
       '';
     });

  buildDpdk = version: hash: kPackages:
    let
      origDpdk = callPackage ../pkgs/dpdk.nix { kernel = kPackages.kernel; };
      needsGCC49 = lib.any (v: v == version) ["1.7.1" "1.8.0" "2.0.0" "2.1.0"];
      dpdk = if needsGCC49
             then (origDpdk.override { stdenv = overrideCC stdenv gcc48;})
             else origDpdk;
    in dpdk.overrideDerivation (super: {
      name = "dpdk-${version}-${kPackages.kernel.version}";
      inherit version;
      prePatch = ''
        find . -type f -exec sed -i 's/-Werror//' {} \;
      '';
      src = fetchurl {
        url = "http://dpdk.org/browse/dpdk/snapshot/dpdk-${version}.tar.gz";
        sha256 = hash;
      };
    });

  # define software stacks

  snabbs = [
    (buildSnabb "2016.03" "0wr54m0vr49l51pqj08z7xnm2i97x7183many1ra5bzzg5c5waky")
    (buildSnabb "2016.04" "1b5g477zy6cr5d9171xf8zrhhq6wxshg4cn78i5bki572q86kwlx")
    (buildSnabb "2016.05" "1xd926yplqqmgl196iq9lnzg3nnswhk1vkav4zhs4i1cav99ayh8")
  ];
  dpdks = kPackages: map (dpdk: dpdk kPackages) [
    (buildDpdk "16.07" "1sgh55w3xpc0lb70s74cbyryxdjijk1fbv9b25jy8ms3lxaj966c")
    (buildDpdk "16.04" "0yrz3nnhv65v2jzz726bjswkn8ffqc1sr699qypc9m78qrdljcfn")
    (buildDpdk "2.2.0" "03b1pliyx5psy3mkys8j1mk6y2x818j6wmjrdvpr7v0q6vcnl83p")
    (buildDpdk "2.1.0" "0h1lkalvcpn8drjldw50kipnf88ndv2wvflgkkyrmya5ga325czp")
    (buildDpdk "2.0.0" "0gzzzgmnl1yzv9vs3bbdfgw61ckiakgqq93b9pc4v92vpsiqjdv4")
    (buildDpdk "1.8.0" "0f8rvvp2y823ipnxszs9lh10iyiczkrhh172h98kb6fr1f1qclwz")
    # TODO: needs older glibc
    #(buildDpdk "1.7.1" "0yd60ww5xhf0dfl2x1pqx1m2363b2b7zp89mcya86j20gi3bgvlx")
  ];
  qemus = [
    (buildQemu "2.1.3" "0h0ayrlr4kj74fb920mv0wh9d11d0nvnm70wplwijh3cdw7gss4v" true)
    (buildQemu "2.1.3" "0h0ayrlr4kj74fb920mv0wh9d11d0nvnm70wplwijh3cdw7gss4v" false)
    (buildQemu "2.2.1" "181m2ddsg3adw8y5dmimsi8x678imn9f6i5p20zbhi7pdr61a5s6" false)
    (buildQemu "2.3.1" "0px1vhkglxzjdxkkqln98znv832n1sn79g5inh3aw72216c047b6" false)
    (buildQemu "2.4.1" "0xx1wc7lj5m3r2ab7f0axlfknszvbd8rlclpqz4jk48zid6czmg3" false)
    (buildQemu "2.5.1" "0b2xa8604absdmzpcyjs7fix19y5blqmgflnwjzsp1mp7g1m51q2" false)
    (buildQemu "2.6.0" "1v1lhhd6m59hqgmiz100g779rjq70pik5v4b3g936ci73djlmb69" false)
  ];
  kernelPackages = [
    linuxPackages_3_14
    linuxPackages_3_18
    linuxPackages_4_1
    linuxPackages_4_3
    linuxPackages_4_4
  ];

  # functions for building benchmark executing

  dpdkports = {
    base  = "program/snabbnfv/test_fixtures/nfvconfig/test_functions/snabbnfv-bench.port";
    nomrg = "program/snabbnfv/test_fixtures/nfvconfig/test_functions/snabbnfv-bench-no-mrg_rxbuf.port";
    noind = "program/snabbnfv/test_fixtures/nfvconfig/test_functions/snabbnfv-bench-no-indirect_desc.port";
  };

  iperfports = {
    base         = "program/snabbnfv/test_fixtures/nfvconfig/test_functions/same_vlan.ports";
    filter       = "program/snabbnfv/test_fixtures/nfvconfig/test_functions/filter.ports";
    ipsec        = "program/snabbnfv/test_fixtures/nfvconfig/test_functions/crypto.ports";
    l2tpv3       = "program/snabbnfv/test_fixtures/nfvconfig/test_functions/tunnel.ports";
    l2tpv3_ipsec = "program/snabbnfv/test_fixtures/nfvconfig/test_functions/crypto-tunnel.ports";
  };

  mkMatrixBenchBasic = { snabb, ... }@attrs:
    mkSnabbBenchTest (attrs.defaults or {} // {
      name = "basic1_snabb=${versionToAttribute snabb.version or ""}_packets=100e6";
      hardware = "murren";
      inherit (attrs) snabb;
      checkPhase = ''
        /var/setuid-wrappers/sudo ${snabb}/bin/snabb snabbmark basic1 100e6 |& tee $out/log.txt
      '';
      meta = {
        snabbVersion = snabb.version or "";
        toCSV = drv: ''
          score=$(awk '/Mpps/ {print $(NF-1)}' < ${drv}/log.txt)
          ${writeCSV drv "basic" "Mpps"}
        '';
    };
     });
  mkMatrixBenchNFVIperf = { snabb, qemu, kPackages, conf ? "NA", hardware ? "lugano", ... }@attrs:
    mkSnabbBenchTest (attrs.defaults or {} // {
      name = "iperf_conf=${conf}_snabb=${versionToAttribute snabb.version or ""}_kernel=${versionToAttribute kPackages.kernel.version}_qemu=${versionToAttribute qemu.version}";
      inherit (attrs) snabb qemu;
      inherit hardware;
      testNixEnv = mkNixTestEnv { inherit kPackages; };
      meta = {
        inherit conf;
        snabbVersion = snabb.version or "";
        qemuVersion = qemu.version;
        kernelVersion = kPackages.kernel.version;
        toCSV = drv: ''
          score=$(awk '/^IPERF-/ { print $2 }' < ${drv}/log.txt)
          ${writeCSV drv "iperf" "Gbps"}
       '';
      };
      needsNixTestEnv = true;
      checkPhase = ''
        export SNABB_IPERF_BENCH_CONF=${iperfports.${conf} or ""}
        cd src
        /var/setuid-wrappers/sudo -E program/snabbnfv/selftest.sh bench |& tee $out/log.txt
      '';
    });
  mkMatrixBenchNFVDPDK = { snabb, qemu, kPackages, dpdk, ... }@attrs:
    mkSnabbBenchTest (attrs.defaults or {} // {
      name = "l2fwd_snabb=${versionToAttribute snabb.version or ""}_dpdk=${versionToAttribute dpdk.version}_qemu=${versionToAttribute qemu.version}";
      inherit (attrs) snabb qemu;
      needsNixTestEnv = true;
      testNixEnv = mkNixTestEnv { inherit kPackages dpdk; };
      isDPDK = true;
      # TODO: get rid of this
      __useChroot = false;
      hardware = "lugano";
      meta = {
        snabbVersion = snabb.version or "";
        qemuVersion = qemu.version;
        kernelVersion = kPackages.kernel.version;
        dpdkVersion = dpdk.version;
        toCSV = drv: ''
          score=$(awk '/^Rate\(Mpps\):/ { print $2 }' < ${drv}/log.txt)
          ${writeCSV drv "l2fwd" "Mpps"}
       '';
      };
      checkPhase = ''
        cd src
        /var/setuid-wrappers/sudo -E timeout 120 program/snabbnfv/packetblaster_bench.sh |& tee $out/log.txt
      '';
    });
  # using Soft NIC
  mkMatrixBenchSoftNFVDPDK = { snabb, qemu, kPackages, dpdk, pktsize, conf, ... }@attrs:
      mkSnabbBenchTest (attrs.defaults or {} // {
        name = "l2fwd_pktsize=${pktsize}_conf=${conf}_snabb=${versionToAttribute snabb.version or ""}_dpdk=${versionToAttribute dpdk.version}_qemu=${versionToAttribute qemu.version}";
        inherit (attrs) snabb qemu;
        needsNixTestEnv = true;
        testNixEnv = mkNixTestEnv { inherit kPackages dpdk; };
        isDPDK = true;
        # TODO: get rid of this
        __useChroot = false;
        hardware = "murren";
        meta = {
          inherit pktsize conf;
          snabbVersion = snabb.version or "";
          qemuVersion = qemu.version;
          kernelVersion = kPackages.kernel.version;
          dpdkVersion = dpdk.version;
          toCSV = drv: ''
            score=$(awk '/^Rate\(Mpps\):/ { print $2 }' < ${drv}/log.txt)
            ${writeCSV drv "l2fwd" "Mpps"}
         '';
        };
        checkPhase = ''
          cd src

          export SNABB_PACKET_SIZES=${pktsize}
          export SNABB_DPDK_BENCH_CONF=${dpdkports.${conf}}
          /var/setuid-wrappers/sudo -E timeout 160 program/snabbnfv/dpdk_bench.sh |& tee $out/log.txt
        '';
      });
  mkMatrixBenchPacketblaster = { snabb, ... }@attrs:
    mkSnabbBenchTest (attrs.defaults or {} // {
      name = "${snabb.name}-packetblaster-64";
      inherit (attrs) snabb;
      hardware = "lugano";
      meta = {
        snabbVersion = snabb.version or "";
        toCSV = drv: ''
          pps=$(cat ${drv}/log.txt | grep TXDGPC | cut -f 3 | sed s/,//g)
          score=$(echo "scale=2; $pps / 1000000" | bc)
          ${writeCSV drv "blast" "Mpps"}
        '';
      };
      checkPhase = ''
        cd src
        /var/setuid-wrappers/sudo ${snabb}/bin/snabb packetblaster replay --duration 1 \
          program/snabbnfv/test_fixtures/pcap/64.pcap "$SNABB_PCI_INTEL0" |& tee $out/log.txt
      '';
    });
  mkMatrixBenchPacketblasterSynth = { snabb, ... }@attrs:
    mkSnabbBenchTest (attrs.defaults or {} // {
      name = "${snabb.name}-packetblaster-synth-64";
      inherit (attrs) snabb;
      hardware = "lugano";
      meta = {
        snabbVersion = snabb.version or "";
        toCSV = drv: ''
          pps=$(cat ${drv}/log.txt | grep TXDGPC | cut -f 3 | sed s/,//g)
          score=$(echo "scale=2; $pps / 1000000" | bc)
          ${writeCSV drv "blastsynth" "Mpps"}
        '';
      };
      checkPhase = ''
        /var/setuid-wrappers/sudo ${snabb}/bin/snabb packetblaster synth \
          --src 11:11:11:11:11:11 --dst 22:22:22:22:22:22 --sizes 64 \
          --duration 1 "$SNABB_PCI_INTEL0" |& tee $out/log.txt
      '';
    });


  # Functions providing commands to convert logs to CSV

  writeCSV = drv: benchName: unit: ''
    if test -z "$score"; then score="NA"; fi
    echo ${benchName},${drv.meta.pktsize or "NA"},${drv.meta.conf or "NA"},${drv.meta.snabbVersion or "NA"},${drv.meta.kernelVersion or "NA"},${drv.meta.qemuVersion or "NA"},${drv.meta.dpdkVersion or "NA"},${toString drv.meta.repeatNum},$score,${unit} >> $out/bench.csv
  '';

  # generate CSV out of logs
  # TODO: uses writeText until following is merged https://github.com/NixOS/nixpkgs/pull/15803
  mkBenchmarkCSV = benchmarkList: stdenv.mkDerivation {
    name = "snabb-report-csv";
    buildInputs = [ pkgs.gawk pkgs.bc ];
    preferLocalBuild = true;
    builder = writeText "csv-builder.sh" ''
      source $stdenv/setup
      mkdir -p $out/nix-support

      echo "benchmark,pktsize,config,snabb,kernel,qemu,dpdk,id,score,unit" > $out/bench.csv
      ${lib.concatMapStringsSep "\n" (drv: drv.meta.toCSV drv) benchmarkList}

      # Make CSV file available via Hydra
      echo "file CSV $out/bench.csv" >> $out/nix-support/hydra-build-products
    '';
   };

   # use writeText until runCommand uses passAsFile (16.09)
   mkBenchmarkReport = benchmark-csv: benchmarks-list: reportName: stdenv.mkDerivation {
     name = "snabb-report";
     buildInputs = [ rPackages.rmarkdown rPackages.ggplot2 rPackages.dplyr R pandoc which ];
     preferLocalBuild = true;
     builder = writeText "csv-builder.sh" ''
       source $stdenv/setup

       # Store all logs
       mkdir -p $out/nix-support
       ${lib.concatMapStringsSep "\n" (drv: "cat ${drv}/log.txt > $out/${drv.name}-${toString drv.meta.repeatNum}.log") benchmarks-list}
       tar cfJ logs.tar.xz -C $out .
       mv logs.tar.xz $out/
       echo "file tarball $out/logs.tar.xz" >> $out/nix-support/hydra-build-products

       # Create markdown report
       cp ${../lib/reports + "/${reportName}.Rmd"} ./report.Rmd
       cp ${benchmark-csv}/bench.csv .
       cat bench.csv
       cat report.Rmd
       echo "library(rmarkdown); render('report.Rmd')" | R --no-save
       cp report.html $out
       echo "file HTML $out/report.html"  >> $out/nix-support/hydra-build-products
       echo "nix-build out $out" >> $out/nix-support/hydra-build-products
     '';
   };

   # Given a list of names and parameters to pass, collect benchmarks by their name and pass them the parameters
   selectBenchmarks = names: params:
     map (name: (lib.getAttr name benchmarks) params) names;

   # helper function for package selections
   matchesVersionPrefix = version: drv:
     lib.hasPrefix version (lib.getVersion drv);

   # Select software collections based on version strings
   selectQemus = versions:
     if versions == []
     then qemus
     else lib.flatten (map (version: lib.filter (matchesVersionPrefix version) qemus) versions);
   selectDpdks = versions: kPackages:
     if versions == []
     then (dpdks kPackages)
     else lib.flatten (map (version: lib.filter (matchesVersionPrefix version) (dpdks kPackages)) versions);
   selectKernelPackages = versions:
     if versions == []
     then kernelPackages
     else lib.flatten (map (version: lib.filter (kPackages: lib.hasPrefix version (lib.getVersion kPackages.kernel)) kernelPackages) versions);

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
     dpdk-soft-base-256 = params: mkMatrixBenchSoftNFVDPDK (params // {pktsize = "256"; conf = "base";});
     dpdk-soft-nomrg-256 = params: mkMatrixBenchSoftNFVDPDK (params // {pktsize = "256"; conf = "nomrg";});
     dpdk-soft-noind-256 = params: mkMatrixBenchSoftNFVDPDK (params // {pktsize = "256"; conf = "noind";});
     dpdk-soft-base-64 = params: mkMatrixBenchSoftNFVDPDK (params // {pktsize = "64"; conf = "base";});
     dpdk-soft-nomrg-64 = params: mkMatrixBenchSoftNFVDPDK (params // {pktsize = "64"; conf = "nomrg";});
     dpdk-soft-noind-64 = params: mkMatrixBenchSoftNFVDPDK (params // {pktsize = "64"; conf = "noind";});
   };
}
