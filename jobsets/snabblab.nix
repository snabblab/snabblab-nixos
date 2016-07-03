{ nixpkgsSrc ? <nixpkgs> }:

with (import nixpkgsSrc {});

let
  mkChannel = { name, src, constituents ? [], meta ? {}, isNixOS ? true, ... }@args:
    stdenv.mkDerivation ({
      preferLocalBuild = true;
      _hydraAggregate = true;

      phases = [ "unpackPhase" "patchPhase" "installPhase" ];

      patchPhase = stdenv.lib.optionalString isNixOS ''
        touch .update-on-nixos-rebuild
      '';

      installPhase = ''
        mkdir -p $out/{tarballs,nix-support}
        tar cJf "$out/tarballs/nixexprs.tar.xz" \
          --owner=0 --group=0 --mtime="1970-01-01 00:00:00 UTC" \
          --transform='s!^\.!${name}!' .
        echo "channel - $out/tarballs/nixexprs.tar.xz" > "$out/nix-support/hydra-build-products"
        echo $constituents > "$out/nix-support/hydra-aggregate-constituents"
        for i in $constituents; do
          if [ -e "$i/nix-support/failed" ]; then
            touch "$out/nix-support/failed"
          fi
        done
      '';

      meta = meta // {
        isHydraChannel = true;
      };
    } // removeAttrs args [ "meta" ]);
  nixpkgsShortRev = nixpkgsSrc.shortRev or "abcdefg";
  nixpkgsVersion = "git-${toString nixpkgsSrc.revCount or 12345}.${nixpkgsShortRev}-snabblab";
  mkChannelWithNixpkgs = { ... }@args:
    let
      src = stdenv.mkDerivation {
        name = args.name + "-with-nixpkgs";
        src = args.src;
        phases = [ "unpackPhase" "installPhase" ];
        installPhase = ''
          cp -r --no-preserve=ownership "${nixpkgsSrc}/" nixpkgs

          # denote nixpkgs versioning
          chmod -R u+w nixpkgs
          echo "echo '${nixpkgsVersion}'" > nixpkgs/nixos/modules/installer/tools/get-version-suffix
          echo -n "${nixpkgsVersion}" > nixpkgs/.version-suffix
          echo -n ${nixpkgsShortRev} > nixpkgs/.git-revision

          cp -r . $out
        '';
      };
    in mkChannel (args // { inherit src; });
   machines = import ../machines;
in {
  machines = stdenv.lib.genAttrs ["build1" "build2" "build3" "build4"]
    (name: mkChannelWithNixpkgs {
      name = "snabblab-machine-${name}";
      constituents = [ machines.${name}.eval.config.system.build.toplevel ];
      src = ./../.;
    });

  # build all our custom packages
  inherit (import ./../pkgs { pkgs = (import nixpkgsSrc {}); }) snabbpkgs;
}
