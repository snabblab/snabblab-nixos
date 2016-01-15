{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # develoment tools
    gcc git gnumake wget
    # editors
    emacs vim
  ];
}
