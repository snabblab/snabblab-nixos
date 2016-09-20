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
        url = "http://dpdk.org/browse/dpdk/snapshot/dpdk-${version}.tar.gz";
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
      prePatch = ''
        find . -type f -exec sed -i 's/-Werror//' {} \;
      '';
      inherit src;
    });

  # Define software stacks using a list

  # DPDKs are a special case, because they need kernelPackages as input to build
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
    pkgs.linuxPackages_3_14
    pkgs.linuxPackages_3_18
    pkgs.linuxPackages_4_1
    pkgs.linuxPackages_4_3
    pkgs.linuxPackages_4_4
  ];
}
