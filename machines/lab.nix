let
  cfg = { config, pkgs, lib, ... }: {
    require = [
      ./../modules/lab-configuration.nix
    ];

    boot.loader.grub.enable = true;
    boot.loader.grub.devices = [ "/dev/sda" ];
    boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "ehci_pci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];

    fileSystems = [
      { mountPoint = "/"; fsType = "ext4"; label = "root"; }
    ];
  };
in {
  network.description = "Snabb Lab machines";

  lugano-1 = cfg;
  lugano-2 = cfg;
  lugano-3 = cfg;
  lugano-4 = cfg;

  # TODO: grindelwald & chur (interlaken is currently used)
}
