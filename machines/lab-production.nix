let
  mkMachine = ip:
    { config, pkgs, lib, ... }: {
      deployment.targetEnv = "none";
      deployment.targetHost = ip;
    };
in {
  lugano-1 = mkMachine "195.176.0.211";
  lugano-2 = mkMachine "195.176.0.212";
  lugano-3 = mkMachine "195.176.0.213";
  lugano-4 = mkMachine "195.176.0.214";
}
