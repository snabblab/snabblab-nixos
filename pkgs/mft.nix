{ stdenv, fetchurl, dpkg, file, glibc, gcc, linux, kmod, pciutils }:

stdenv.mkDerivation rec {
  name = "mft-${version}";
  version = "4.4.0-44";

  src = fetchurl {
    url = "http://www.mellanox.com/downloads/MFT/${name}.tgz";
    sha256 = "1psfb67k9pqqayjgdnkb0fchrh2h35d0r1w26m696czn1svsahyq";
  };

  buildInputs = [ dpkg file ];

  postUnpack = ''
    dpkg-deb -R $sourceRoot/SDEBS/kernel-mft-dkms_${version}_all.deb $TMPDIR
    dpkg-deb -R $sourceRoot/DEBS/mft-${version}.amd64.deb $TMPDIR
    dpkg-deb -R $sourceRoot/DEBS/mft-oem-${version}.amd64.deb $TMPDIR
  '';

  patchPhase = ''
    substituteInPlace $TMPDIR/etc/init.d/mst \
      --replace "/sbin/modprobe" "${kmod}/bin/modprobe" \
      --replace "/usr/bin/lspci" "${pciutils}/bin/lspci" \
      --replace "/sbin/lsmod" "${kmod}/bin/lsmod"
    substituteInPlace $TMPDIR/etc/mft/mft.conf \
      --replace "/usr" "$out"

  '';

  # build kernel modules
  buildPhase = ''
    pushd $TMPDIR/usr/src/kernel-mft-dkms-*
    make KSRC=${linux.dev}/lib/modules/${linux.modDirVersion}/build 
    mkdir -p $out/lib/modules/${linux.modDirVersion}/
    cp *.ko $out/lib/modules/${linux.modDirVersion}/
    popd
  '';

  installPhase = ''
    mkdir -p $out
    cp -r $TMPDIR/{etc,usr/{bin,lib64,share}} $out
    substituteInPlace $out/etc/init.d/mst --replace "mbindir=/usr/bin" "mbindir=$out/bin"
    unlink $out/bin/mst
    ln -sf $out/etc/init.d/mst $out/bin/mst
    for BIN in $(find $out/bin -type f); do
      if $(file $BIN | grep -q "ELF"); then
        echo Patching $BIN
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" --set-rpath "${glibc}/lib:${gcc.cc}/lib:$out/lib" $BIN
      else
        substituteInPlace $BIN --replace "mbindir=/usr/bin" "mbindir=$out/bin"
      fi
    done
  '';

  # check all ELF files to have their dependencies
  checkPhase = ''
    for BIN in $(ls $out/bin); do
      if $(file $BIN | grep "ELF"); then
        # Test our binary to see if it was correctly patched
        set +e
        ldd $BIN | grep -q -v "not found"
        ST="$?"
        set -e
        if [ "$ST" -ge "0" ]; then
          echo "Failed testing $BIN"
          exit 1;
        fi
      fi
    done
  '';

  dontStrip = true;
}
