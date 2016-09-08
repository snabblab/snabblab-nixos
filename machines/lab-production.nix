let
  mkHetzner = ip: { config, pkgs, lib, ... }: {
    deployment.targetEnv = "hetzner";
    deployment.hetzner.mainIPv4 = ip;
    deployment.hetzner.partitions = ''
      clearpart --all --initlabel --drives=sda,sdb

      part raid.3 --size=8192 --ondisk=sda
      part raid.4 --size=8192 --ondisk=sdb
      part raid.1 --size=1 --grow --ondisk=sda
      part raid.2 --size=1 --grow --ondisk=sdb

      raid /    --level=1 --fstype=ext4 --device=md0 --label=root raid.1 raid.2
      raid swap --level=1 --fstype=swap --device=md1 raid.3 raid.4
    '';
  };

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
  davos = mkMachine { ip = "lab1.snabb.co"; port = 2000; useGummiboot = false; };
  snabb2 = mkMachine { ip = "igalia.com"; port = 4041; useGummiboot = false; };

  # Hydra (CI) servers

  murren-1 = mkHetzner "138.201.65.94";
  murren-2 = mkHetzner "138.201.65.96";
  murren-3 = mkHetzner "138.201.65.98";
  murren-4 = mkHetzner "138.201.65.99";
  murren-5 = mkHetzner "138.201.65.132";
  murren-6 = mkHetzner "138.201.65.135";
  murren-7 = mkHetzner "138.201.65.138";
  murren-8 = mkHetzner "138.201.65.142";
  murren-9 = mkHetzner "138.201.65.143";
  murren-10 = mkHetzner "138.201.65.147";

  #eiger  = mkHetzner "136.243.111.220";
  #build-1 = mkHetzner "46.4.65.79";
  #build-2 = mkHetzner "78.46.84.196";
  #build-3 = mkHetzner "78.46.98.22";
  #build-4 = mkHetzner "46.4.108.125";

}
