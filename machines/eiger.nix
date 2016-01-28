{
  network.description = "Snabb Lab supporting server";

  eiger = { config, pkgs, ... }: {
    require = [
      ./../modules/common.nix
    ];

    # User for nixops deployments
    users.extraUsers.deploy = {
      uid = 2001;
      description = "deploy";
      group = "deploy";
      isNormalUser = true;
    };
    users.extraGroups.deploy.gid = 2001;

    services.openssh = {
      enable = true;
    };

    # samba is used for ISO booting for lab servers
    users.extraUsers.smbguest = {
      uid = 2000;
      description = "smbguest";
      group = "smbguest";
    };
    users.extraGroups.smbguest.gid = 2000;

    networking.firewall.enable = true;
    services.samba = {
      enable = true;
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
}
