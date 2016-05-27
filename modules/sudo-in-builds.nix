{ config, pkgs, lib, ... }:

# allows sudo in chroots by introducing some impurities
# has to be available on all servers for builds to always have those paths available inside chroot

{
  nix.chrootDirs = [
    "/var/setuid-wrappers"
    "${pkgs.sudo}"
    "/etc/sudoers"
    "/etc/passwd"
    "/etc/pam.d/sudo"
    "/etc/static/pam.d/sudo"
    (toString (pkgs.writeText "sudo.pam" config.security.pam.services.sudo.text))
    "/sys"
  ];


  # legacy/deprecated solution (no chroot)
  nix.useChroot = lib.mkForce "relaxed";
  security.sudo.extraConfig = lib.concatMapStringsSep "\n" (i: "nixbld${toString i} ALL=(ALL) NOPASSWD:ALL") (lib.range 1 config.nix.nrBuildUsers);
}
