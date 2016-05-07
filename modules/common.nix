{ config, pkgs, ... }:

{
  require = [
    ./users.nix
  ];

  i18n.defaultLocale = "en_US.UTF-8";

  # extend nixpkgs with our own package
  nixpkgs.config.packageOverrides = pkgs: {
    inherit (import ./../pkgs { inherit pkgs; }) snabbpkgs;
  };

  # let's make sure only NixOS can handle users
  users.mutableUsers = false;

  # less paranoia
  networking.firewall.allowPing = true;

  # see https://github.com/NixOS/nixpkgs/commit/ee8e15fe76a235ae3583d4e8cb4bb370f28c5eae
  programs.bash.enableCompletion = true;

  environment.systemPackages = with pkgs; [
    # develoment tools
    gcc glibc git gnumake wget nmap screen tmux pciutils tcpdump curl strace htop
    file cpulimit numactl speedtest-cli w3m psmisc xterm wgetpaste
    config.boot.kernelPackages.perf nox ipmitool
    # manpages
    manpages
    posix_man_pages
    # editors
    vim
    (emacsWithPackages (epkgs: [ epkgs.lua-mode ]))
    snabbpkgs.lock
  ];

  nix = rec {
    # allow users to use nix-env
    nixPath = [ "nixpkgs=http://nixos.org/channels/nixos-16.03/nixexprs.tar.xz" ];

    # use nix sandboxing for greater determinism
    useChroot = true;

    # make sure we have enough build users
    nrBuildUsers = 30;

    # if our hydra is down, don't wait forever
    extraOptions = ''
      connect-timeout = 10
    '';

    # use our hydra builds
    trustedBinaryCaches = [ "https://cache.nixos.org" "https://hydra.snabb.co" ];
    binaryCaches = trustedBinaryCaches;
    binaryCachePublicKeys = [ "hydra.snabb.co-1:zPzKSJ1mynGtYEVbUR0QVZf9TLcaygz/OyzHlWo5AMM=" ];
  };

  # make sure channel information is updated from above
  # TODO: enable once https://github.com/snabblab/snabblab-nixos/issues/14 is fixed
  #system.activationScripts.snabblab = ''
  #  /run/current-system/sw/bin/nix-channel --update
  #'';

  # lets users use sudo without password
  security.sudo.wheelNeedsPassword = false;

  # direct root access with pub key
  users.extraUsers.root.openssh.authorizedKeys.keys = config.users.extraUsers.domenkozar.openssh.authorizedKeys.keys;
}
