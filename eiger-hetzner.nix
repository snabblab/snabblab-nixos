{
  eiger = { config, pkgs, lib, ... }: {
    deployment.targetEnv = "hetzner";
    deployment.hetzner.mainIPv4 = "136.243.111.220";
    deployment.hetzner.partitions = ''
      clearpart --all --initlabel --drives=sda

      part swap.1 --recommended --label=swap --fstype=swap --ondisk=sda
      part swap.2 --recommended --label=swap --fstype=swap --ondisk=sdb

      part raid.1 --size=6000 --ondisk=sda
      part raid.2 --size=6000 --ondisk=sdb

      raid / --level=1 --fstype=ext4 --label=root --device=md0 raid.1 raid.2
    '';
  };
}
