{ stdenv, fetchurl, dpkg, file, glibc, gcc, linux, kmod, pciutils }:

stdenv.mkDerivation rec {
  name = "mft-${version}";
  version = "4.3.0-25";

  src = fetchurl {
    url = "http://www.mellanox.com/downloads/MFT/${name}.tgz";
    sha256 = "0vmx8s6fqqrwjwsyaqkmfbjg4xr3gp3rk8xjkczz37i8r6qq5d5j";
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
  '';

  buildPhase = ''
    pushd $TMPDIR/usr/src/kernel-mft-dkms-4.3.0
    make KSRC=${linux.dev}/lib/modules/${linux.modDirVersion}/build 
    mkdir -p $out/kmod
    cp *.ko $out/kmod/
    popd
  '';

  installPhase = ''
    mkdir -p $out
    cp -r $TMPDIR/{etc,usr/{bin,lib64,share}} $out
    for BIN in $(find $out/bin -type f); do
      if $(file $BIN | grep -q "ELF"); then
        echo Patching $BIN
        patchelf --set-interpreter "${glibc}/lib/ld-linux-x86-64.so.2" --set-rpath "${glibc}/lib:${gcc.cc}/lib:$out/lib" $BIN
      fi
    done
  '';

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
