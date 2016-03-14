{ config, pkgs, ... }:

{
  require = [
    ./users.nix
  ];

  i18n.defaultLocale = "en_US.UTF-8";

  # use nix sandboxing for greater determinism
  nix.useChroot = true;

  # make sure we have enough build users
  nix.nrBuildUsers = 30;

  # extend nixpkgs with our own package
  nixpkgs.config.packageOverrides = pkgs: {
    inherit (import ./../pkgs { inherit pkgs; });
  };

  # let's make sure only NixOS can handle users
  users.mutableUsers = false;

  # less paranoia
  networking.firewall.allowPing = true;

  environment.systemPackages = with pkgs; [
    # develoment tools
    gcc glibc git gnumake wget nmap screen tmux pciutils
    # editors
    vim
    (emacsWithPackages (epkgs: [ epkgs.lua-mode ]))
  ];

  # allow users to use nix-env
  nix.nixPath = [ "nixpkgs=http://nixos.org/channels/nixos-unstable/nixexprs.tar.xz" ];

  # lets users use sudo without password
  security.sudo.wheelNeedsPassword = false;

  # direct root access with pub key
  users.extraUsers.root.openssh.authorizedKeys.keys = config.users.extraUsers.domenkozar.openssh.authorizedKeys.keys;
}
