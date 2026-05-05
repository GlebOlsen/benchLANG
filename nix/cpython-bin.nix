{ lib, stdenv, fetchurl, makeWrapper }:

# python-build-standalone (Astral) — fully self-contained CPython.
# Do NOT autoPatchelf — its bundled libs are tuned to load relative to install root.
# Just extract and wrap to set LD_LIBRARY_PATH to its own lib dir.
stdenv.mkDerivation rec {
  pname = "cpython-bin";
  version = "3.14.4";
  pbsTag = "20260414";

  src = fetchurl {
    url = "https://github.com/astral-sh/python-build-standalone/releases/download/${pbsTag}/cpython-${version}+${pbsTag}-x86_64-unknown-linux-gnu-install_only.tar.gz";
    hash = "sha256-4XJ16vlc61h3qmgW4gm3cz9B/uQB05w5IbiPtz/EpLo=";
  };

  nativeBuildInputs = [ makeWrapper ];

  sourceRoot = "python";
  dontBuild = true;
  dontConfigure = true;
  dontPatchELF = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r ./* $out/
    # Wrap python3 / python to load its own bundled libs first
    for binname in python python3 python3.14; do
      if [ -e "$out/bin/$binname" ] && [ ! -L "$out/bin/$binname" ]; then
        mv "$out/bin/$binname" "$out/bin/.$binname-real"
        makeWrapper "$out/bin/.$binname-real" "$out/bin/$binname" \
          --prefix LD_LIBRARY_PATH : "$out/lib"
      fi
    done
    runHook postInstall
  '';

  meta = with lib; {
    description = "CPython ${version} portable build (Astral python-build-standalone)";
    homepage = "https://github.com/astral-sh/python-build-standalone";
    license = licenses.psfl;
    platforms = [ "x86_64-linux" ];
  };
}
