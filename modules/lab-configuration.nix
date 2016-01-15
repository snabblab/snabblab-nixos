{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "devicemapper";
  environment.systemPackages = with pkgs; [ docker ];

  services.openssh.enable = true;
}
