{ config, pkgs, lib, ... }:

# allows sudo in chroots by introducing some impurities
# has to be available on all servers for builds to always have those paths available inside chroot

with pkgs;

let
  # use sudo without pam (eaiser in chroots)
  sudoChroot = sudo.overrideDerivation (super: {
    buildInputs = [ coreutils groff ];
    postInstall = ''
      ln -s $out/bin/sudo $out/bin/sudo-chroot
    '';
  });
in {
  nix.chrootDirs = [
    "/var/setuid-wrappers/sudo=/var/setuid-wrappers/sudo-chroot"
    "/var/setuid-wrappers/sudo.real=/var/setuid-wrappers/sudo-chroot.real"
    "${sudoChroot}"
    "/etc/sudoers"
    "/etc/passwd"
    "/sys"
  ];
  environment.systemPackages = [ (lowPrio sudoChroot) ];
  security.setuidPrograms = [ "sudo-chroot" ];

  # legacy/deprecated solution (no chroot)
  nix.useChroot = lib.mkForce "relaxed";
  security.sudo.extraConfig = lib.concatMapStringsSep "\n" (i: "nixbld${toString i} ALL=(ALL) NOPASSWD:ALL") (lib.range 1 config.nix.nrBuildUsers);
}
