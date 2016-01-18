{
  network.description = "Snabb Lab supporting server";

  eiger = { config, pkgs, ... }: {
    require = [
      ./modules/common.nix
    ];

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

    # For IPMIView
    environment.systemPackages = with pkgs; [ x11vnc ];
  };
}
