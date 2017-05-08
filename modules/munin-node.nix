{ config, pkgs, lib, ... }:

with lib;

let
  hostnameSuffix =
    if (hasSuffix ".snabb.co" config.networking.hostName)
    then ""
    else ".snabb.co";
in {
  services.munin-node.enable = true;
  # It should match the hostname used on Munin master
  services.munin-node.extraConfig = ''
    host_name ${config.networking.hostName}${hostnameSuffix}
  '';

  users.extraUsers.munin.shell = "${pkgs.bash}/bin/bash";
  users.extraUsers.munin.openssh.authorizedKeys.keys = pkgs.lib.singleton ''
    command="${pkgs.utillinux}/bin/flock -x /var/lock/lab nc localhost 4949" ${pkgs.lib.readFile ./../secrets/id_buildfarm.pub}
  '';
}
