with (import ../lib {});

let
  defaults = {
    require = [
      ./../modules/lab-configuration.nix
    ];
  };
in {
  network.description = "Snabb Lab machines";

  lugano-1 = { config, pkgs, lib, ... }: defaults // {
      environment.variables = PCIAssignments.lugano;

      # custom NixOS options here
  };
  lugano-2 = { config, pkgs, lib, ... }: defaults // {
      environment.variables = PCIAssignments.lugano;

      # custom NixOS options here
  };
  lugano-3 = { config, pkgs, lib, ... }: defaults // {
      environment.variables = PCIAssignments.lugano;

      # custom NixOS options here
  };
  lugano-4 = { config, pkgs, lib, ... }: defaults // {
      environment.variables = PCIAssignments.lugano;

      # custom NixOS options here
  };
  davos = { config, pkgs, lib, ... }: defaults // {
      # custom NixOS options here
      services.snabb_bot.environment =
        ''
          export SNABB_TEST_IMAGE=eugeneia/snabb-nfv-test-vanilla
          export SNABB_PCI0=0000:03:00.0
          export SNABB_PCI1=0000:03:00.1
          export SNABB_PCI_INTEL0=0000:03:00.0
          export SNABB_PCI_INTEL1=0000:03:00.1
          export SNABB_PCI_INTEL1G0=0000:01:00.0
          export SNABB_PCI_INTEL1G1=0000:01:00.1
        '';
      imports = [ ./../modules/snabb_bot.nix ./../modules/snabb_doc.nix ];
  };
  grindelwald = { config, pkgs, lib, ... }: defaults // {
      # custom NixOS options here

      # OpenStack requirements
      boot.extraModprobeConfig = "options kvm-intel nested=y";
      boot.kernelModules = [ "pci-stub" ];
      boot.kernelParams = lib.mkForce [ "intel_iommu=on" "hugepages=4096" ];
      boot.blacklistedKernelModules = [ "ixgbe" ];
  };
  interlaken = { config, pkgs, lib, ... }: defaults // {
      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/8AB0-B6D9";
        fsType = "vfat";
      };

      # custom NixOS options here
  };
  snabb2 = { config, pkgs, lib, ... }: defaults // {
    boot.kernelParams = [ 
      "default_hugepagesz=2048K"
      "hugepagesz=2048K"
      "hugepages=10000"
      "intel_iommu=off"
      "isolcpus=1-5,7-11" 
    ];
    boot.kernelModules = [ "9p" "9pnet" "9pnet_virtio" ];
    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/d12e8f61-46f9-475d-b377-0659b1a0e59e";
        fsType = "ext4";
      };
    networking.interfaces.enp4s0f0.ip4 = [
      { address = "192.168.13.41"; prefixLength = 24; }
    ];
    networking.defaultGateway = "192.168.13.1";
    networking.nameservers = [ "192.168.13.1" ];
    networking.firewall.allowedTCPPorts = [ 22 4040 4041 ];
    services.openssh.ports = [ 22 4040 4041 ];
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

