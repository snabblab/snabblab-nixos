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
  environment.systemPackages = with pkgs; [ docker ];

  services.openssh.enable = true;

  # allow users to use nix-env
  nix.nixPath = [ "nixpkgs=https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz" ];

  # use latests kernel
  boot.kernelPackages = pkgs.linuxPackages_4_3;

  # Disable IOMMU for Snabb Switch.
  # chur has a Sandy Bridge CPU and these are known to have
  # performance problems in their IOMMU.
  boot.kernelParams = [ "intel_iommu=pt" "hugepages=4096" "panic=60"];

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
