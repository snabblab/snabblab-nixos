{ pkgs }:

# build* functions are responsible for building software given their source or version

rec {
  # Build Snabb using git version tag
  buildSnabb = version: hash:
    pkgs.snabbswitch.overrideDerivation (super: {
      name = "snabb-${version}";
      inherit version;
      src = pkgs.fetchFromGitHub {
        owner = "snabbco";
        repo = "snabb";
        rev = "v${version}";
        sha256 = hash;
      };
    });

 # Build snabb using nix store path provided by builtins.fetchTarball or Hydra git input
 buildNixSnabb = snabbSrc: version:
   if snabbSrc == null
   then null
   else
      (pkgs.callPackage snabbSrc {}).overrideDerivation (super:
        {
          name = super.name + version;
          inherit version;
        }
      );

  buildQemu = version: hash: applySnabbPatch:
    let
      src = pkgs.fetchurl {
        url = "http://wiki.qemu.org/download/qemu-${version}.tar.bz2";
        sha256 = hash;
      };
    in buildQemuFromSrc version src applySnabbPatch;

  buildQemuFromSrc = version: src: applySnabbPatch:
    let
      snabbPatch = pkgs.fetchurl {
        url = "https://github.com/SnabbCo/qemu/commit/f393aea2301734647fdf470724433f44702e3fb9.patch";
        sha256 = "0hpnfdk96rrdaaf6qr4m4pgv40dw7r53mg95f22axj7nsyr8d72x";
        name = "snabb-patch";
      };
    in pkgs.qemu.overrideDerivation (super: {
      name = "qemu-${version}" + pkgs.lib.optionalString applySnabbPatch "-with-snabbpatch";
      version = version + pkgs.lib.optionalString applySnabbPatch "-with-snabbpatch";
      inherit src;
      patchPhase = ''
        substituteInPlace Makefile --replace \
          "install-datadir install-localstatedir" \
          "install-datadir" \
          --replace "install-sysconfig " ""
      '' + pkgs.lib.optionalString applySnabbPatch ''
        patch -p1 < ${snabbPatch}
      '';
    });

  buildDpdk = version: hash: kPackages:
    let
      src = pkgs.fetchurl {
        url = "http://fast.dpdk.org/rel/dpdk-${version}.tar.xz";
        sha256 = hash;
      };
    in buildDpdkFromSrc version src kPackages;

  buildDpdkFromSrc = version: src: kPackages:
    let
      origDpdk = pkgs.callPackage ../pkgs/dpdk.nix { kernel = kPackages.kernel; };
      needsGCC49 = pkgs.lib.any (v: v == version) ["1.7.1" "1.8.0" "2.0.0" "2.1.0"];
      dpdk = if needsGCC49
             then (origDpdk.override { stdenv = pkgs.overrideCC pkgs.stdenv pkgs.gcc48;})
             else origDpdk;
    in dpdk.overrideDerivation (super: {
      name = "dpdk-${version}-${kPackages.kernel.version}";
      inherit version;
      hardeningDisable = ["stackprotector" "pic"];
      prePatch = ''
        find . -type f -exec sed -i 's/-Werror//' {} \;
      '';
      inherit src;
    });

  # Define software stacks using a list

  # DPDKs are a special case, because they need kernelPackages as input to build
  dpdks = kPackages: map (dpdk: dpdk kPackages) [
    (buildDpdk "16.11" "0yji91q0q5vgl8gd2r01zzq9a6q7rgz04bkjq84qr06sy0bk14p2")
    (buildDpdk "16.07.1" "10729ahbcknhhbjdcw3kw8avmi5yq83jd6qvmnc36qzv2scni372")
    (buildDpdk "16.04" "1fwqljvg0lr94qlba2xzn3zqg1jcbj4yz450k72fgj4mqpjsdmys")
    (buildDpdk "2.2.0" "1yfgcbnc4zk3dc9iva166i32h320z0aw5spy96bziy9r6ma6g4bq")
    (buildDpdk "2.1.0" "1pnna7ww4rnhyqn0jgdgdqa7h4w0ysr2dv70229fhamxy65lsn4p")
    (buildDpdk "2.0.0" "0yz33hsfk821h2mby69v63nm9c22k7ial1520blcx6c2qz3jll6f")
#    (buildDpdk "1.8.0" "1h15n0bhm3f2d8nihy8w5139yi5bidvy70p16m7pv4jw2kiiz4f6")
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
    (buildQemu "2.6.2" "18zsjz11fxnv8yh2nfc59ifrp1kiwbmh03j11ibix7kv2i7wczls" false)
#    (buildQemu "2.7.1" "13wm4941r0qp48l4r4raf7annpa9a0mv68529fsb1g39xf46fqv8" false)
#    (buildQemu "2.8.0" "0qjy3rcrn89n42y5iz60kgr0rrl29hpnj8mq2yvbc1wrcizmvzfs" false)
  ];

  kernelPackages = [
    pkgs.linuxPackages_3_14
    pkgs.linuxPackages_3_18
    pkgs.linuxPackages_4_1
    pkgs.linuxPackages_4_3
    pkgs.linuxPackages_4_4
  ];
}
