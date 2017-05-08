# build an ISO image that will auto install NixOS and reboot
# $ nix-build make-iso.nix

let
   config = (import <nixpkgs/nixos/lib/eval-config.nix> {
     system = "x86_64-linux";
     modules = [
       <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
       ({ pkgs, lib, ... }:
         let
           cfg = pkgs.writeText "configuration.nix" ''
            { config, pkgs, lib, ... }:

            {
              boot.loader.grub.enable = true;
              boot.loader.grub.devices = [ "/dev/sda" ];
              boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "ehci_pci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];

              services.openssh.enable = true;
              services.openssh.permitRootLogin = "yes";
              users.extraUsers.root.initialPassword = lib.mkForce "OhPha3gu";

              # this is set for install not to ask for password
              users.mutableUsers = false;

              fileSystems = [
                { mountPoint = "/"; fsType = "ext4"; label = "root"; }
              ];
            }
           '';
           partitions = pkgs.writeText "partitions" ''
             clearpart --all --initlabel --drives=sda
             part swap --size=512 --ondisk=sda
             part / --fstype=ext4 --label=root --grow --ondisk=sda
           '';
         in {
           services.openssh.permitRootLogin = "yes";
           users.extraUsers.root.initialPassword = lib.mkForce "OhPha3gu";
           systemd.services.inception = {
             description = "Self-bootstrap a NixOS installation";
             wantedBy = [ "multi-user.target" ];
             after = [ "network.target" "polkit.service" ];
             # TODO: submit a patch for blivet upstream to unhardcode kmod/e2fsprogs/utillinux
             path = [ "/run/current-system/sw/" ];
             script = with pkgs; ''
               sleep 5
               ${pythonPackages.nixpart0}/bin/nixpart ${partitions}
               mkdir -p /mnt/etc/nixos/
               cp ${cfg} /mnt/etc/nixos/configuration.nix
               ${config.system.build.nixos-install}/bin/nixos-install -j 4
               ${systemd}/bin/shutdown -r now
             '';
             environment = config.nix.envVars // {
               inherit (config.environment.sessionVariables) NIX_PATH SSL_CERT_FILE;
               HOME = "/root";
             };
             serviceConfig = {
               Type = "oneshot";
             };
          };
       })
     ];
   }).config;
in
  config.system.build.isoImage
