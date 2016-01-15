{
  network.description = "Snabb Lab supporting server";

  eiger = { config, pkgs, ... }: {
    imports = [
      ./modules/users.nix
    ];

    services.openssh.enable = true;
  };
}
