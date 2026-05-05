{ lib, stdenv, fetchurl, autoPatchelfHook, makeWrapper, icu, libunwind, libuuid
, openssl, zlib, krb5, lttng-ust_2_12 }:

stdenv.mkDerivation rec {
  pname = "dotnet-sdk-bin";
  version = "10.0.203";

  src = fetchurl {
    url = "https://builds.dotnet.microsoft.com/dotnet/Sdk/${version}/dotnet-sdk-${version}-linux-x64.tar.gz";
    hash = "sha256-Q04QnGBMVeRfTTF5V7Ti8JPuGc7szbf4gLl731uW+jI=";
  };

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];
  buildInputs = [
    stdenv.cc.cc.lib
    icu
    libunwind
    libuuid
    openssl
    zlib
    krb5
    lttng-ust_2_12
  ];

  sourceRoot = ".";
  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/dotnet
    cp -r ./* $out/share/dotnet/
    mkdir -p $out/bin
    # ICU is dlopen'd at runtime — wrap to expose libicu via LD_LIBRARY_PATH
    makeWrapper $out/share/dotnet/dotnet $out/bin/dotnet \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ icu openssl ]} \
      --set DOTNET_ROOT $out/share/dotnet \
      --set DOTNET_CLI_TELEMETRY_OPTOUT 1
    runHook postInstall
  '';

  meta = with lib; {
    description = ".NET SDK ${version} (upstream binary)";
    homepage = "https://dotnet.microsoft.com/";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
