{ lib, stdenv, fetchurl, autoPatchelfHook, openssl }:

stdenv.mkDerivation rec {
  pname = "nim-bin";
  version = "2.2.10";

  src = fetchurl {
    url = "https://nim-lang.org/download/nim-${version}-linux_x64.tar.xz";
    hash = "sha256-Cjo4dS6X6dRKpHmzp7NzNt/gF22vIu5bUhitCZHs0hE=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib openssl ];

  dontBuild = true;
  dontConfigure = true;

  # Nim invokes a C compiler at runtime — provided by gcc15 also in the devShell PATH.
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    # Nim needs bin + lib + config/nim.cfg (stdlib path resolution).
    cp -r bin lib config $out/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Nim compiler ${version} (upstream binary tarball)";
    homepage = "https://nim-lang.org/";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
