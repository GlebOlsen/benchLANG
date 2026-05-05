{
  description = "benchLANG — programming language runtime benchmarks";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import rust-overlay) ];
          config.allowUnfree = true;
        };

        # Latest stable Rust from rust-overlay (currently 1.95.x)
        rustToolchain = pkgs.rust-bin.stable.latest.default;

        # Binary fallbacks for langs lagging in nixpkgs master
        nimBin = pkgs.callPackage ./nix/nim-bin.nix { };
        dotnetBin = pkgs.callPackage ./nix/dotnet-bin.nix { };
        jdkBin = pkgs.callPackage ./nix/jdk-bin.nix { };
        cpythonBin = pkgs.callPackage ./nix/cpython-bin.nix { };
      in
      {
        devShells.default = pkgs.mkShell {
          name = "benchLANG";

          packages = with pkgs; [
            # GCC family — nixpkgs master is 15.2.0. GCC 16 has no Linux binary
            # distribution upstream (gcc.gnu.org ships source only). To bump,
            # use nix/gcc16.nix.bak (renamed) — builds 16.1 from source ~90 min.
            gcc15        # C / C++
            gfortran15   # Fortran
            gnat15       # Ada (default `gnat` attr is gnat13 — pin 15)


            # D — gdc removed (bootstrap issues), DMD 2.110 broken vs gcc15 (C23 nullptr).
            # LDC is the performance compiler anyway.
            ldc

            # Go
            go

            # JS
            bun
            nodejs_25

            # OCaml
            ocaml

            # Pascal
            fpc

            # PHP
            php85

            # PyPy
            pypy3

            # Zig
            zig_0_16

            # Dart
            dart

            # Rust (oxalica overlay — latest stable)
            rustToolchain

            # Binary fallbacks
            nimBin
            dotnetBin
            jdkBin
            cpythonBin

            # Misc utils
            coreutils
            gnumake
            gnused
            gawk
            which
          ];

          shellHook = ''
            # Allow -march=native / -mcpu=native in benchmark builds.
            # Nix stdenv sets NIX_ENFORCE_NO_NATIVE=1 to keep store paths host-portable;
            # we explicitly want native code-gen for accurate CPU benchmarks.
            unset NIX_ENFORCE_NO_NATIVE
            export NIX_ENFORCE_NO_NATIVE=0

            echo "==============================================="
            echo "  benchLANG dev shell"
            echo "==============================================="
            echo "GCC:     $(gcc --version | head -n1)"
            echo "Go:      $(go version)"
            echo "Bun:     $(bun --version)"
            echo "Node:    $(node --version)"
            echo "OCaml:   $(ocamlopt --version)"
            echo "FPC:     $(fpc -iV)"
            echo "PHP:     $(php --version | head -n1)"
            echo "PyPy:    $(pypy3 --version 2>&1 | head -n1)"
            echo "Zig:     $(zig version)"
            echo "Dart:    $(dart --version 2>&1)"
            echo "LDC:     $(ldc2 --version | head -n1)"
            echo "Rust:    $(rustc --version)"
            echo "Nim:     $(nim --version | head -n1)"
            echo ".NET:    $(dotnet --version)"
            echo "Java:    $(java --version | head -n1)"
            echo "CPython: $(python3 --version)"
            echo "GNAT:    $(gnat --version | head -n1)"
            echo "==============================================="
          '';
        };
      });
}
