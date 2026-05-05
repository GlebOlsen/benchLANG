{ lib, stdenv, fetchurl, autoPatchelfHook, alsa-lib, cups, fontconfig
, freetype, libX11, libXext, libXi, libXrender, libXtst, zlib }:

stdenv.mkDerivation rec {
  pname = "jdk-temurin-bin";
  version = "25";
  build = "36";

  src = fetchurl {
    url = "https://github.com/adoptium/temurin${version}-binaries/releases/download/jdk-${version}%2B${build}/OpenJDK${version}U-jdk_x64_linux_hotspot_${version}_${build}.tar.gz";
    hash = "sha256-7gTelaudpyh9QL0hcwduzCpt1mLwB77fxusDgMDvkOg=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    stdenv.cc.cc.lib
    alsa-lib
    cups
    fontconfig
    freetype
    libX11
    libXext
    libXi
    libXrender
    libXtst
    zlib
  ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r ./* $out/
    runHook postInstall
  '';

  meta = with lib; {
    description = "Eclipse Temurin OpenJDK ${version} LTS (upstream binary)";
    homepage = "https://adoptium.net/";
    license = licenses.gpl2Plus;
    platforms = [ "x86_64-linux" ];
  };
}
