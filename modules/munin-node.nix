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

  users.extraUsers.munin.openssh.authorizedKeys.keys = pkgs.lib.singleton ''
    command="/run/current-system/sw/bin/false" ${pkgs.lib.readFile ./../secrets/id_buildfarm.pub}
  '';
}
