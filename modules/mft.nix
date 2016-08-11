{ config, pkgs, lib, ... }:


let
  mft = pkgs.snabbpkgs.mft.override { linux = config.boot.kernelPackages.kernel; };
in {
  boot.extraModulePackages = [ mft ];
  environment.systemPackages = [ mft ];
  environment.etc = [
    { source = "${mft}/etc/mft";
      target = "mft";
    }
  ];

  nixpkgs.config = {
    packageOverrides = pkgs: {
      stdenv = pkgs.stdenv // {
        platform = pkgs.stdenv.platform // {
          kernelExtraConfig = ''
            MLX5_CORE_EN y
            MLX4_INFINIBAND n
            MLX5_INFINIBAND n
            DYNAMIC_DEBUG y
          '';
        };
      }; 
    };
  };
}
