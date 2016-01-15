{
  network.description = "Snabb Lab supporting server";

  eiger = { config, pkgs, ... }: {
    imports = [
      ./modules/users.nix
      ./modules/common.nix
    ];

    services.openssh.enable = true;
  };
}
