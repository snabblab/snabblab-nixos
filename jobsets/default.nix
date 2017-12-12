{ snabbPrsJSON ? ./simple-pr-dummy.json
, nixpkgs ? <nixpkgs>
, declInput ? {}
}:

# Followed by https://github.com/NixOS/hydra/pull/418/files

let
  pkgs = import nixpkgs {};
  snabbPrs = builtins.fromJSON (builtins.readFile snabbPrsJSON);
  mkFetchGithub = value: {
    inherit value;
    type = "git";
    emailresponsible = false;
  };
  defaultSettings = {
    enabled = 1;
    hidden = false;
    nixexprinput = "snabblab";
    keepnr = 5;
    schedulingshares = 42;
    checkinterval = 60;
    inputs = {
      nixpkgs = mkFetchGithub "https://github.com/NixOS/nixpkgs-channels.git nixos-16.03";
      snabblab = mkFetchGithub "https://github.com/snabblab/snabblab-nixos.git master";
    };
    enableemail = false;
    emailoverride = "";
  };
  makeSnabbPR = num: info: {
    name = "snabb-pr-${num}";
    value = defaultSettings // {
      description = "PR ${num}: ${info.title}";
      nixexprpath = "jobsets/snabb.nix";
      inputs = defaultSettings.inputs // {
        snabbSrc = mkFetchGithub "https://github.com/${info.head.repo.owner.login}/${info.head.repo.name}.git ${info.head.ref}";
        lwaftrSrc = mkFetchGithub "https://github.com/${info.head.repo.owner.login}/${info.head.repo.name}.git ${info.head.ref}";
      };
    };
  };
  snabbPrJobsets = pkgs.lib.listToAttrs (pkgs.lib.mapAttrsToList makeSnabbPR snabbPrs);
in {
  jobsets = with pkgs.lib; pkgs.runCommand "spec.json" {} ''
    cat <<EOF
    ${builtins.toJSON declInput}
    EOF
    cp ${pkgs.writeText "spec.json" (builtins.toJSON (snabbPrJobsets))} $out
  '';
}
