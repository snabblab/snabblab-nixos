{ config, pkgs, ... }:

{
  require = [
    ./users.nix
  ];

  # less paranoia
  networking.firewall.allowPing = true;

  environment.systemPackages = with pkgs; [
    # develoment tools
    gcc glibc git gnumake wget nmap screen tmux
    # editors
    vim
    (emacsWithPackages (epkgs: [ epkgs.lua-mode ]))
  ];

  # allow users to use nix-env
  nix.nixPath = [ "nixpkgs=http://nixos.org/releases/nixos/unstable-small/nixos-16.03pre77014.1c8a21d/nixexprs.tar.xz" ];

  # lets users use sudo without password
  security.sudo.wheelNeedsPassword = false;

  # direct root access with pub key
  users.extraUsers.root.openssh.authorizedKeys.keys = config.users.extraUsers.domenkozar.openssh.authorizedKeys.keys;
}
