{
  eiger = { config, pkgs, lib, ... }: {
    deployment.targetEnv = "hetzner";
    deployment.hetzner.mainIPv4 = "136.243.111.220";
    deployment.hetzner.partitions = ''
      clearpart --all --initlabel --drives=sda
      part swap --recommended --label=swap --fstype=swap --ondisk=sda
      part / --fstype=ext4 --label=root --grow --ondisk=sda
    '';
    # if we don't set this, it tries to install bootloader on sdb
    boot.loader.grub.devices = lib.mkForce ["/dev/sda"];
  };
}
