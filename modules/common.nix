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
    inherit (import ./../pkgs { inherit pkgs; }) snabbpkgs;
  };

  # let's make sure only NixOS can handle users
  users.mutableUsers = false;

  # less paranoia
  networking.firewall.allowPing = true;

  environment.systemPackages = with pkgs; [
    # develoment tools
    gcc glibc git gnumake wget nmap screen tmux pciutils tcpdump curl strace htop
    file cpulimit numactl speedtest-cli w3m psmisc xterm
    config.boot.kernelPackages.perf
    # editors
    vim
    (emacsWithPackages (epkgs: [ epkgs.lua-mode ]))
    snabbpkgs.lock
  ];

  # allow users to use nix-env
  nix.nixPath = [ "nixpkgs=http://nixos.org/channels/nixos-16.03-beta/nixexprs.tar.xz" ];

  # make sure channel information is updated from above
  system.activationScripts.snabblab = ''
    /run/current-system/sw/bin/nix-channel --update
  '';

  # lets users use sudo without password
  security.sudo.wheelNeedsPassword = false;

  # direct root access with pub key
  users.extraUsers.root.openssh.authorizedKeys.keys = config.users.extraUsers.domenkozar.openssh.authorizedKeys.keys;
}
