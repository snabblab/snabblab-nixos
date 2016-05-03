{
eiger = {
  config = {
    networking = {
      defaultGateway = "136.243.111.193";
      interfaces.eth0 = { ipAddress = "136.243.111.220"; prefixLength = 26; };
      localCommands = ''
        ip -6 addr add '2a01:4f8:171:125b::/64' dev 'eth0' || true
        ip -4 route change '136.243.111.192/26' via '136.243.111.193' dev 'eth0' || true
        ip -6 route add default via 'fe80::1' dev eth0 || true
      '';
      nameservers = [
        "213.133.98.98"
        "213.133.99.99"
        "213.133.100.100"
        "2a01:4f8:0:a0a1::add:1010"
        "2a01:4f8:0:a102::add:9999"
        "2a01:4f8:0:a111::add:9898"
      ];
    };
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="90:1b:0e:8b:11:15", NAME="eth0"
    '';
    users.extraUsers.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKQucTZ4iUufjr4+ViyvvuBufsMw7RbIkgoEgQxA+4e1 NixOps client key of eiger"
    ];
  };
  imports = [
    ({
      swapDevices = [
        { label = ""; }
      ];
      boot.loader.grub.devices = [
        "/dev/sda"
        "/dev/sdb"
      ];
      fileSystems = {
        "/" = {
          fsType = "ext4";
          label = "root";
        };
      };
    })
    ({ config, lib, pkgs, ... }:
    
    {
      imports = [ ];
    
      boot.initrd.availableKernelModules = [ "ahci" "sd_mod" ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];
    
      nix.maxJobs = 8;
    })
  ];
};
build4 = {
  config = {
    networking = {
      defaultGateway = "46.4.108.97";
      interfaces.eth0 = { ipAddress = "46.4.108.125"; prefixLength = 27; };
      localCommands = ''
        ip -6 addr add '2a01:4f8:141:4ed::/64' dev 'eth0' || true
        ip -4 route change '46.4.108.96/27' via '46.4.108.97' dev 'eth0' || true
        ip -6 route add default via 'fe80::1' dev eth0 || true
      '';
      nameservers = [
        "213.133.98.98"
        "213.133.99.99"
        "213.133.100.100"
        "2a01:4f8:0:a0a1::add:1010"
        "2a01:4f8:0:a102::add:9999"
        "2a01:4f8:0:a111::add:9898"
      ];
    };
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="6c:62:6d:d9:0a:a7", NAME="eth0"
    '';
    users.extraUsers.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB/YASrAWOUiSu57feqS7JUp/enRULZLTWZ/9GUbQ2Qb NixOps client key of build4"
    ];
  };
  imports = [
    ({
      swapDevices = [
        { label = ""; }
      ];
      boot.loader.grub.devices = [
        "/dev/sda"
        "/dev/sdb"
      ];
      fileSystems = {
        "/" = {
          fsType = "ext4";
          label = "root";
        };
      };
    })
    ({ config, lib, pkgs, ... }:
    
    {
      imports =
        [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
        ];
    
      boot.initrd.availableKernelModules = [ "uhci_hcd" "ahci" "sd_mod" ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];
    
      nix.maxJobs = 8;
    })
  ];
};
build2 = {
  config = {
    networking = {
      defaultGateway = "78.46.84.193";
      interfaces.eth0 = { ipAddress = "78.46.84.196"; prefixLength = 27; };
      localCommands = ''
        ip -6 addr add '2a01:4f8:120:12ac::/64' dev 'eth0' || true
        ip -4 route change '78.46.84.192/27' via '78.46.84.193' dev 'eth0' || true
        ip -6 route add default via 'fe80::1' dev eth0 || true
      '';
      nameservers = [
        "213.133.98.98"
        "213.133.99.99"
        "213.133.100.100"
        "2a01:4f8:0:a0a1::add:1010"
        "2a01:4f8:0:a102::add:9999"
        "2a01:4f8:0:a111::add:9898"
      ];
    };
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="40:61:86:be:d1:f1", NAME="eth0"
    '';
    users.extraUsers.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINt/FiCtK2N1ZJJalRGzDsotmb4IqFN2ntUa5jbiagsb NixOps client key of build2"
    ];
  };
  imports = [
    ({
      swapDevices = [
        { label = ""; }
      ];
      boot.loader.grub.devices = [
        "/dev/sda"
        "/dev/sdb"
      ];
      fileSystems = {
        "/" = {
          fsType = "ext4";
          label = "root";
        };
      };
    })
    ({ config, lib, pkgs, ... }:
    
    {
      imports =
        [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
        ];
    
      boot.initrd.availableKernelModules = [ "uhci_hcd" "ahci" "sd_mod" ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];
    
      nix.maxJobs = 8;
    })
  ];
};
build3 = {
  config = {
    networking = {
      defaultGateway = "78.46.98.1";
      interfaces.eth0 = { ipAddress = "78.46.98.22"; prefixLength = 27; };
      localCommands = ''
        ip -6 addr add '2a01:4f8:120:8390::/64' dev 'eth0' || true
        ip -4 route change '78.46.98.0/27' via '78.46.98.1' dev 'eth0' || true
        ip -6 route add default via 'fe80::1' dev eth0 || true
      '';
      nameservers = [
        "213.133.98.98"
        "213.133.99.99"
        "213.133.100.100"
        "2a01:4f8:0:a0a1::add:1010"
        "2a01:4f8:0:a102::add:9999"
        "2a01:4f8:0:a111::add:9898"
      ];
    };
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="40:61:86:e9:d5:86", NAME="eth0"
    '';
    users.extraUsers.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOxOUSJcUMnB+JJonQ6ZCg2WBOtlKm1kkfD6uyLULh2G NixOps client key of build3"
    ];
  };
  imports = [
    ({
      swapDevices = [
        { label = ""; }
      ];
      boot.loader.grub.devices = [
        "/dev/sda"
        "/dev/sdb"
      ];
      fileSystems = {
        "/" = {
          fsType = "ext4";
          label = "root";
        };
      };
    })
    ({ config, lib, pkgs, ... }:
    
    {
      imports =
        [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
        ];
    
      boot.initrd.availableKernelModules = [ "uhci_hcd" "ahci" "sd_mod" ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];
    
      nix.maxJobs = 8;
    })
  ];
};
build1 = {
  config = {
    networking = {
      defaultGateway = "46.4.65.65";
      interfaces.eth0 = { ipAddress = "46.4.65.79"; prefixLength = 26; };
      localCommands = ''
        ip -6 addr add '2a01:4f8:140:23b3::/64' dev 'eth0' || true
        ip -4 route change '46.4.65.64/26' via '46.4.65.65' dev 'eth0' || true
        ip -6 route add default via 'fe80::1' dev eth0 || true
      '';
      nameservers = [
        "213.133.98.98"
        "213.133.99.99"
        "213.133.100.100"
        "2a01:4f8:0:a0a1::add:1010"
        "2a01:4f8:0:a102::add:9999"
        "2a01:4f8:0:a111::add:9898"
      ];
    };
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="00:24:21:5b:a3:a1", NAME="eth0"
    '';
    users.extraUsers.root.openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII7cOfoJfD+DOjyu8wQSPszykSamYA75z9pGNKMOEjlV NixOps client key of build1"
    ];
  };
  imports = [
    ({
      swapDevices = [
        { label = ""; }
      ];
      boot.loader.grub.devices = [
        "/dev/sda"
        "/dev/sdb"
      ];
      fileSystems = {
        "/" = {
          fsType = "ext4";
          label = "root";
        };
      };
    })
    ({ config, lib, pkgs, ... }:
    
    {
      imports =
        [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
        ];
    
      boot.initrd.availableKernelModules = [ "uhci_hcd" "ahci" "sd_mod" ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];
    
      nix.maxJobs = 8;
    })
  ];
};
}
