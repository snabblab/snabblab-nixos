{ config, pkgs, ... }:

{
  require = [
    ./common.nix
  ];
  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "devicemapper";
  environment.systemPackages = with pkgs; [ docker ];

  services.openssh.enable = true;

  # lets users use sudo without password
  security.sudo.wheelNeedsPassword = false;

  # crashes with NICs
  boot.blacklistedKernelModules = [ "i40e" ];
}
