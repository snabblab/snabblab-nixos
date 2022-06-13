# Build two NixOS Qemu guest images:

# qemu_img: Plain NixOS guest with some tools

{ pkgs, nixpkgs }:

{ kPackages ? pkgs.linuxPackages }:
   let
      # modules and NixOS config for plain qemu image
      snabb_modules = [
        "${nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
        ({config, pkgs, ...}: {
          # Needed tools inside the guest
          environment.systemPackages = with pkgs; [ inetutils screen python pciutils ethtool tcpdump ipsecTools nmap (hiPrio netcat-openbsd) iperf2 ];

          fileSystems."/".device = "/dev/disk/by-label/nixos";
          boot.loader.grub.device = "/dev/sda";

          # Options needed by tests
          boot.kernelPackages = kPackages;
          networking.firewall.enable = pkgs.lib.mkOverride 150 false;
          services.mingetty.autologinUser = "root";
          users.extraUsers.root.initialHashedPassword = pkgs.lib.mkOverride 150 "";
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
      snabb_config = (import "${nixpkgs}/nixos/lib/eval-config.nix" { modules = snabb_modules; }).config;

      qemu_img = pkgs.lib.makeOverridable (import "${nixpkgs}/nixos/lib/make-disk-image.nix") {
        inherit pkgs;
        lib = pkgs.lib;
        config = snabb_config;
        partitioned = true;
        format = "raw";
        diskSize = 2 * 1020;
      };
      in pkgs.runCommand "test-env-nix" {} ''
        mkdir -p $out
        ln -s ${qemu_img}/nixos.img $out/qemu.img
        ln -s ${snabb_config.system.build.kernel}/bzImage $out/bzImage
        ln -s ${snabb_config.system.build.toplevel}/initrd $out/initrd
      ''
