let
  mkMachine = ip:
    { config, pkgs, lib, ... }: {
      deployment.targetEnv = "none";
      deployment.targetHost = ip;

      boot.loader.grub.enable = true;
      boot.loader.grub.devices = [ "/dev/sda" ];
      boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "ehci_pci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];

      fileSystems = [
        { mountPoint = "/"; fsType = "ext4"; label = "root"; }
      ];
    };
in {
  lugano-1 = mkMachine "195.176.0.211";
  lugano-2 = mkMachine "195.176.0.212";
  lugano-3 = mkMachine "195.176.0.213";
  lugano-4 = mkMachine "195.176.0.214";
}
