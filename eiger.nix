{
  network.description = "Snabb Lab supporting server";

  eiger = { config, pkgs, ... }: {
    require = [
      ./modules/common.nix
    ];

    services.openssh.enable = true;
  };
}
