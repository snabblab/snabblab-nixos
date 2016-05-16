let
  defaults = {
    require = [
      ./../modules/lab-configuration.nix
    ];
  };
in {
  network.description = "Snabb Lab machines";

  lugano-1 = { config, pkgs, lib, ... }: defaults // {
      # custom NixOS options here
  };
  lugano-2 = { config, pkgs, lib, ... }: defaults // {
      require = [
        ./../modules/lab-configuration.nix
      ];
      # custom NixOS options here
      boot.kernelParams = lib.mkForce [ "intel_iommu=off" "hugepages=4096" "panic=60" ];
  };
  lugano-3 = { config, pkgs, lib, ... }: defaults // {
      # custom NixOS options here
      boot.kernelParams = lib.mkForce [ "intel_iommu=off" "hugepages=4096" "panic=60" ];
      #boot.extraModprobeConfig = "options kvm-intel nested=y";
      #boot.kernelModules = [ "pci-stub" ];
      #boot.kernelParams = lib.mkForce [ "intel_iommu=on" "hugepages=4096" ];
      #boot.blacklistedKernelModules = [ "ixgbe" ];
  };
  lugano-4 = { config, pkgs, lib, ... }: defaults // {
      # custom NixOS options here
  };
  grindelwald = { config, pkgs, lib, ... }: defaults // {
      # custom NixOS options here
  };
  interlaken = { config, pkgs, lib, ... }: defaults // {
      fileSystems."/boot" = { 
        device = "/dev/disk/by-uuid/8AB0-B6D9";
        fsType = "vfat";
      };

      # custom NixOS options here
  };

  # Hydra (CI) servers

  murren-1 = defaults;
  murren-2 = defaults;
  murren-3 = defaults;
  murren-4 = defaults;
  murren-5 = defaults;
  murren-6 = defaults;
  murren-7 = defaults;
  murren-8 = defaults;
  murren-9 = defaults;
  murren-10 = defaults;
}

