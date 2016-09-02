# Build two NixOS Qemu guest images:

# qemu_img: Plain NixOS guest with some tools like 
# dpdk_img: Same as the above plus dpdk l2fwd tied to an interface

{ pkgs }:

{ kPackages ? linuxPackages
, dpdk ? linuxPackages.dpdk }:
   let
     # modules and NixOS config for plain qemu image
     snabb_modules = [
       <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
       ({config, pkgs, ...}: {
         # Needed tools inside the guest
         environment.systemPackages = with pkgs; [ inetutils screen python pciutils ethtool tcpdump (hiPrio netcat-openbsd) iperf2 ];

         fileSystems."/".device = "/dev/disk/by-label/nixos";
         boot.loader.grub.device = "/dev/sda";

         # Options needed by tests
         boot.kernelPackages = kPackages;
         networking.firewall.enable = lib.mkOverride 150 false;
         services.mingetty.autologinUser = "root";
         users.extraUsers.root.initialHashedPassword = lib.mkOverride 150 "";
         networking.usePredictableInterfaceNames = false;

         # Make sure telnet serial port is enabled
         systemd.services."serial-getty@ttyS0".wantedBy = [ "multi-user.target" ];

         # Redirect all processes to the serial console.
         services.journald.extraConfig = ''
           ForwardToConsole=yes
           MaxLevelConsole=debug
         '';
       })
     ];
     snabb_config = (import <nixpkgs/nixos/lib/eval-config.nix> { modules = snabb_modules; }).config;

     # modules and NixOS config for dpdk qmemu image
     snabb_modules_dpdk = [
       ({config, pkgs, lib, ...}:
         let
           dpdk_bind = fetchurl {
             url = "https://raw.githubusercontent.com/scylladb/dpdk/8ea56fadc9a49c575bee6bb3892bc17dd9ec4ab6/tools/dpdk_nic_bind.py";
             sha256 = "0z8big9gh49q9kh0jjg1p9g5ywwvb130r3bmhhpbgx7blhk9zb7f";
           };
         in {
           systemd.services.dpdk = {
             wantedBy = [ "multi-user.target" ];
             after = [ "network.target" ];
             path = with pkgs; [ kmod python pciutils iproute utillinux ];
             script = ''
               mkdir -p /hugetlbfs
               mount -t hugetlbfs nodev /hugetlbfs
               echo 64 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages
               MODULE_DIR=/run/current-system/kernel-modules/lib/modules modprobe uio
               insmod ${dpdk}/kmod/igb_uio.ko
               python ${dpdk_bind} --bind=igb_uio 00:03.0
               ${dpdk.examples}/l2fwd/x86_64-native-linuxapp-gcc/l2fwd -c 0x1 -n1 -- -p 0x1
             '';
           };
         }
       )
     ];
     snabb_config_dpdk = (import <nixpkgs/nixos/lib/eval-config.nix> { modules = snabb_modules_dpdk ++ snabb_modules; }).config;
     qemu_img = lib.makeOverridable (import <nixpkgs/nixos/lib/make-disk-image.nix>) {
       inherit lib pkgs;
       config = snabb_config;
       partitioned = true;
       format = "raw";
       diskSize = 2 * 1020;
     };
     qemu_dpdk_img = qemu_img.override { config = snabb_config_dpdk; };
   in runCommand "test-env-nix-${dpdk.name}" {} ''
     mkdir -p $out
     ln -s ${qemu_img}/nixos.img $out/qemu.img
     ln -s ${qemu_dpdk_img}/nixos.img $out/qemu-dpdk.img
     ln -s ${snabb_config.system.build.kernel}/bzImage $out/bzImage
     ln -s ${snabb_config.system.build.toplevel}/initrd $out/initrd
   ''
