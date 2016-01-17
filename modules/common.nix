{ config, pkgs, ... }:

{
  require = [
    ./users.nix
  ];

  environment.systemPackages = with pkgs; [
    # develoment tools
    gcc git gnumake wget
    # editors
    emacs vim
  ];
}
