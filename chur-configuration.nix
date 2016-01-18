# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  require = [
    ./chur-hardware-configuration.nix
    ./modules/lab-configuration.nix
  ];

  # Use the gummiboot efi boot loader.
  boot.loader.gummiboot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable kernel MSR module
  nixpkgs.config = {
    packageOverrides = pkgs: {
      stdenv = pkgs.stdenv // {
        kernelExtraConfig = "X86_MSR m" ;
      };
    };
  };

  networking.hostName = "chur"; # Define your hostname.
  networking.hostId = "1ab1e8b1";
  # networking.wireless.enable = true;  # Enables wireless.

  nix.nrBuildUsers = 32;
}
