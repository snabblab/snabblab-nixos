let
  build-slave = { config, pkgs, ... }: {
    require = [
      ./../modules/common.nix
      ./../modules/hydra-slave.nix
    ];
    services.openssh.enable = true;
  };
in {
  network.description = "Snabb Lab supporting server";

  eiger = { config, pkgs, ... }: {
    require = [
      ./../modules/common.nix
      ./../modules/hydra-master.nix
    ];

    # https://kernelnewbies.org/Linux_4.7#head-cb7faf5c84d36d6bec87c7f9233bfe2d50b0073a
    boot.kernelPackages = pkgs.linuxPackages_4_7;

    # User for nixops deployments
    users.extraUsers.deploy = {
      uid = 2001;
      description = "deploy";
      group = "deploy";
      isNormalUser = true;
      openssh.authorizedKeys.keys = config.users.extraUsers.domenkozar.openssh.authorizedKeys.keys;
    };
    users.extraGroups.deploy.gid = 2001;

    services.openssh.enable = true;

    # samba is used for ISO booting for lab servers
    users.extraUsers.smbguest = {
      uid = 2000;
      description = "smbguest";
      group = "smbguest";
    };
    users.extraGroups.smbguest.gid = 2000;

    networking.firewall.enable = true;
    services.samba = {
      enable = false;
      shares = {
        data =
          { path = "/mnt/samba";
            "read only" = "yes";
            browseable = "yes";
            "guest ok" = "yes";
          };
      };
      extraConfig = ''
        guest account = smbguest
        map to guest = bad user
      '';
    };

    environment.systemPackages = with pkgs; [
      nixops
    ];
  };
  build1 = build-slave;
  build2 = build-slave;
  build3 = build-slave;
  build4 = build-slave;
}
