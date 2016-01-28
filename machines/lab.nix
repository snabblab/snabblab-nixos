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

  # TODO: grindelwald & chur & interlaken
}
