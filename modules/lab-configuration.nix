{ config, pkgs, lib, ... }:

with (import ../lib { inherit pkgs; });

let
  nixTestEnv = mkNixTestEnv {};
in {
  require = [
    ./common.nix
    ./hydra-slave.nix
    ./mft.nix
  ];

  # Docker support
  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "devicemapper";
  # https://github.com/NixOS/nixpkgs/issues/11478
  virtualisation.docker.socketActivation = true;

  # Libvirt support for NixOps deployments
  virtualisation.libvirtd.enable = true;

  environment.systemPackages = with pkgs; [
    docker
    # snabb development libraries/tools
    git telnet tmux numactl bc iproute which qemu utillinux jq mosh
  ];

  # setup Snabb test fixtures
  # TODO: use COW images in snabb to avoid this
  system.activationScripts.snabb = ''
    mkdir -p /var/lib/snabb-test-fixtures/
    for f in ${nixTestEnv}/*; do
      export f_name=$(${pkgs.coreutils}/bin/basename $f)
      if ! ${pkgs.diffutils}/bin/cmp ${nixTestEnv}/$f_name /var/lib/snabb-test-fixtures/$f_name &> /dev/null; then
        cp --no-preserve=mode $f /var/lib/snabb-test-fixtures/
      fi
    done
  '';

  environment.variables.SNABB_TEST_FIXTURES = "/var/lib/snabb-test-fixtures/";
  environment.variables.SNABB_KERNEL_PARAMS = "init=/nix/var/nix/profiles/system/init";
  environment.variables.CURL_CA_BUNDLE = "/etc/ssl/certs/ca-bundle.crt";

  # mount /hugetlbfs for snabbnfv
  systemd.mounts = [
    { where = "/hugetlbfs";
      enable  = true;
      what  = "hugetlbfs";
      type  = "hugetlbfs";
      options = "pagesize=2M";
      requiredBy  = ["basic.target"];
    }
  ];

  users.motd = ''
    Welcome to SnabbLab!

    Basic information can be found at http://snabbco.github.io/#snabblab

    If you have any problems/questions, open an issue at https://github.com/snabblab/snabblab-nixos

    Please use `lock` command when executing commands requiring PCI resources.

  '';

  services.openssh.enable = true;

  # Disable IOMMU for Snabb Switch.
  boot.kernelParams = [ "intel_iommu=off" "hugepages=4096" "panic=60"];

  # For packetlossy connections
  networking.firewall.allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];

  # Used by snabb
  boot.kernelModules = [ "msr" ];

  # crashes with NICs
  boot.blacklistedKernelModules = [ "i40e" ];

  # Luke: it's a PITA for benchmarking because it introduces variation that's hard to control
  # The annoying thing is that Turbo Boost will unpredictably increase the clock speed
  # above its normal value based on stuff like how many cores are in use or temperature of the data center or ...
  boot.postBootCommands = ''
    echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo
    echo 2 > /sys/devices/cpu/rdpmc
  '';
}
