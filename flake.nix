{
  description = "benchLANG programming language runtime benchmarks";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      # mkShell on a GCC 16 stdenv so `gcc`/`g++`/`cc` resolve to 16 and are not
      # shadowed by the default stdenv compiler.
      devShells.${system}.default = (pkgs.mkShell.override { stdenv = pkgs.gcc16Stdenv; }) {
        name = "benchLANG";

        packages = with pkgs; [
          gcc16          # C / C++ (first so `gcc` is not the gfortran wrapper's copy)
          gfortran16     # Fortran
          gnat16         # Ada
          ldc            # D
          rustc
          zig
          go
          nim
          ocaml
          fpc            # Pascal
          jdk25          # Java
          dart
          dotnet-sdk_11  # C#
          bun
          nodejs_26
          php85
          python3        # CPython
          pypy3

          time           # GNU time: wall/user/sys/max RSS per run
          coreutils
          gnumake
          gnused
          gawk
          which
        ];

        shellHook = ''
          # Nix stdenv sets NIX_ENFORCE_NO_NATIVE=1 to keep store paths portable;
          # benchmarks want -march=native.
          unset NIX_ENFORCE_NO_NATIVE
          export NIX_ENFORCE_NO_NATIVE=0

          echo "==============================================="
          echo "  benchLANG dev shell"
          echo "==============================================="
          echo "GCC:     $(gcc --version | head -n1)"
          echo "GNAT:    $(gnat --version | head -n1)"
          echo "LDC:     $(ldc2 --version | head -n1)"
          echo "Rust:    $(rustc --version)"
          echo "Zig:     $(zig version)"
          echo "Go:      $(go version)"
          echo "Nim:     $(nim --version | head -n1)"
          echo "OCaml:   $(ocamlopt --version)"
          echo "FPC:     $(fpc -iV)"
          echo "Java:    $(java --version | head -n1)"
          echo "Dart:    $(dart --version 2>&1)"
          echo ".NET:    $(dotnet --version)"
          echo "Bun:     $(bun --version)"
          echo "Node:    $(node --version)"
          echo "PHP:     $(php --version | head -n1)"
          echo "CPython: $(python3 --version)"
          echo "PyPy:    $(pypy3 --version 2>&1 | head -n1)"
          echo "==============================================="
        '';
      };
    };
}
