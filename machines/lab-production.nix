let
  mkMachine = { ip, port ? 22, useGummiboot ? false }:
    { config, pkgs, lib, ... }: {
      deployment.targetEnv = "none";
      deployment.targetHost = ip;
      deployment.targetPort = port;

      boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "ehci_pci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];

      fileSystems = [
        { mountPoint = "/"; fsType = "ext4"; label = "root"; }
      ];
    } // (if useGummiboot then {
      boot.loader.gummiboot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
    } else {
      boot.loader.grub.enable = true;
      boot.loader.grub.devices = [ "/dev/sda" ];
    });
in {
  lugano-1 = mkMachine { ip = "195.176.0.211"; };
  lugano-2 = mkMachine { ip = "195.176.0.212"; };
  lugano-3 = mkMachine { ip = "195.176.0.213"; };
  lugano-4 = mkMachine { ip = "195.176.0.214"; };

  grindelwald = mkMachine { ip = "lab1.snabb.co"; port = 2010; useGummiboot = true; };
  interlaken = mkMachine { ip = "lab1.snabb.co"; port = 2030; useGummiboot = true; };
}
