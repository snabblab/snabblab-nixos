{ config, pkgs, lib, ... }:

# TODO: sudo in chroot for determinisim?

# Motivation:
# 
# Sometimes it's not possible to execute something as a normal user. For example, pci-assign kernel operation requires root.

# Usage:
#
# stdenv.mkDerivation {
#  __noChroot = true;
#   buildPhase = "/var/setuid-wrappers/sudo ls";

# }

{
  # Make sure that `__noChroot = true;` is respected
  nix.useChroot = lib.mkForce "relaxed";

  # Add all Nix build users to sudoers
  security.sudo.extraConfig = lib.concatMapStringsSep "\n" (i: "nixbld${toString i} ALL=(ALL) NOPASSWD:ALL") (lib.range 1 config.nix.nrBuildUsers);
}
