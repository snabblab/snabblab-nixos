{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "devicemapper";

  services.openssh.enable = true;
}
