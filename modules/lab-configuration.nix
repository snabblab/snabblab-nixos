{ config, pkgs, ... }:

{
  require = [
    ./common.nix
  ];

  # Docker support
  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "devicemapper";
  # https://github.com/NixOS/nixpkgs/issues/11478
  virtualisation.docker.socketActivation = true;

  environment.systemPackages = with pkgs; [
    docker
    # snabbswitch development libraries/tools
    which qemu jq
    # lock command for sharing snabb resources
    lock
  ];

  environment.variables.CURL_CA_BUNDLE = "/etc/ssl/certs/ca-bundle.crt";

  services.openssh.enable = true;

  # Disable IOMMU for Snabb Switch.
  # chur has a Sandy Bridge CPU and these are known to have
  # performance problems in their IOMMU.
  boot.kernelParams = [ "intel_iommu=pt" "hugepages=4096" "panic=60"];

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
