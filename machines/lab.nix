{
  network.description = "Snabb Lab machines";

  lugano-1 = { config, pkgs, lib, ... }: {
      require = [
        ./../modules/lab-configuration.nix
      ];
      # custom NixOS options here
  };
  lugano-2 = { config, pkgs, lib, ... }: {
      require = [
        ./../modules/lab-configuration.nix
      ];
      # custom NixOS options here
  };
  lugano-3 = { config, pkgs, lib, ... }: {
      require = [
        ./../modules/lab-configuration.nix
      ];
      # custom NixOS options here
  };
  lugano-4 = { config, pkgs, lib, ... }: {
      require = [
        ./../modules/lab-configuration.nix
      ];
      # custom NixOS options here
  };
  grindelwald = { config, pkgs, lib, ... }: {
      require = [
        ./../modules/lab-configuration.nix
      ];
      # custom NixOS options here
  };
  interlaken = { config, pkgs, lib, ... }: {
      require = [
        ./../modules/lab-configuration.nix
      ];
      fileSystems."/boot" = { 
        device = "/dev/disk/by-uuid/8AB0-B6D9";
        fsType = "vfat";
      };

      # custom NixOS options here
  };
}
