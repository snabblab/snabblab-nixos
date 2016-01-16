{
  eiger = { config, pkgs, lib, ... }: {
    deployment.targetEnv = "hetzner";
    deployment.hetzner.mainIPv4 = "136.243.111.220";
    deployment.hetzner.partitions = ''
      clearpart --all --initlabel --drives=sda,sdb

      part raid.3 --size=8192 --ondisk=sda
      part raid.4 --size=8192 --ondisk=sdb
      part raid.1 --size=1 --grow --ondisk=sda
      part raid.2 --size=1 --grow --ondisk=sdb

      raid /    --level=1 --fstype=ext4 --device=md0 --label=root raid.1 raid.2
      raid swap --level=1 --fstype=swap --device=md1 raid.3 raid.4
    '';
  };
}
