 # Make a matrix out of Snabb + DPDK + QEMU + Linux (for iperf) 
{}:

with (import <nixpkgs> {});
with (import ../lib.nix);
with vmTools;

let
  # Snabb fixtures

  # modules and NixOS config for plain qemu image
  modules = [
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
    ({config, pkgs, ...}: {
      environment.systemPackages = with pkgs; [ screen python pciutils ethtool tcpdump netcat iperf ];
      fileSystems."/".device = "/dev/disk/by-label/nixos";
      boot.loader.grub.device = "/dev/sda";
    })
  ];
  config = (import <nixpkgs/nixos/lib/eval-config.nix> { inherit modules; }).config;
  # modules and NixOS config gor dpdk qmemu image
  modules_dpdk = modules ++ [({config, pkgs, lib, ...}: {
    # TODO
  })];
  config_dpdk = (import <nixpkgs/nixos/lib/eval-config.nix> { modules = modules_dpdk; }).config;
  # files needed for some tests
  test_env_nix = runCommand "test-env-nix" {} ''
    mkdir -p $out
    ln -s ${qemu_img}/nixos.qcow2 $out/qemu.img
    ln -s ${qemu_dpdk_img}/nixos.qcow2 $out/qemu-dpdk.img
    ln -s ${config.system.build.kernel}/bzImage $out/bzImage
  '';
  qemu_img = lib.makeOverridable (import <nixpkgs/nixos/lib/make-disk-image.nix>) {
    inherit lib config pkgs;
    partitioned = true;
    format = "qcow2";
    diskSize = 2 * 1024;
  };
  qemu_dpdk_img = qemu_img.override { config = config_dpdk; };

  # build the matrix 

  buildSnabb = version: hash:
     snabbswitch.overrideDerivation (attrs: {
       name = "snabb-${version}";
       inherit version;
       src = fetchFromGitHub {
          owner = "snabbco";
          repo = "snabb";
          rev = "v${version}";
          sha256 = hash;
        };
     });
  buildQemu = version: hash:
     qemu.overrideDerivation (attrs: {
       name = lib.replaceChars ["."] [""] "qemu-${version}";
       inherit version;
       src = fetchurl {
          url = "http://wiki.qemu.org/download/qemu-${version}.tar.bz2";
          sha256 = hash;
        };
     });
  snabbs = [
    (buildSnabb "2016.03" "0wr54m0vr49l51pqj08z7xnm2i97x7183many1ra5bzzg5c5waky")
    (buildSnabb "2016.04" "1b5g477zy6cr5d9171xf8zrhhq6wxshg4cn78i5bki572q86kwlx")
    (buildSnabb "2016.05" "1xd926yplqqmgl196iq9lnzg3nnswhk1vkav4zhs4i1cav99ayh8")
  ];
  dpdks = [
  ];
  qemus = [
    (buildQemu "2.3.1" "0qr5aa0vr49l51pqj08z7xnm2i97x7183many1ra5bzzg5c5waka")
    (buildQemu "2.4.1" "0qr5ab0vr49l51pqj08z7xnm2i97x7183many1ra5bzzg5c5waka")
    (buildQemu "2.5.1" "0wr5ac0vr49l51pqj08z7xnm2i97x7183many1ra5bzzg5c5waka")
    (buildQemu "2.6.0" "0wr54m0vr49l51pqj08z7xnm2i97x7183many1ra5bzzg5c5waka")
  ];
  images = [
  ];
in (listDrvToAttrs snabbs)
// (listDrvToAttrs qemus)
