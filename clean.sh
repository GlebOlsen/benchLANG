#!/bin/bash
# Removes compiled artifacts and toolchain caches produced by run_benchmarks.sh.
# Usage: ./clean.sh          run standalone
#        source clean.sh     then call clean_artifacts

set -u

CLEAN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${LANGUAGES_DIR:=$CLEAN_DIR/languages}"

clean_artifacts() {
    local G='\033[0;32m' N='\033[0m'
    declare -A patterns=(
        [Ada]="bench bench.ali bench.o"
        [C]="bench"
        [C++]="bench"
        [D]="bench bench.o"
        [Fortran]="bench bench.o bench.mod"
        [GO]="bench"
        [Java]="bench.class bench\$Node.class"
        [Nim]="bench"
        [OCaml]="bench bench.cmi bench.cmx bench.o monotonic.o"
        [Pascal]="bench bench.o bench.ppu"
        [Rust]="bench"
        [Zig]="bench bench.o"
        [Dart]="bench bench.exe bench.sym"
    )
    local removed=0
    for lang in "${!patterns[@]}"; do
        local dir="$LANGUAGES_DIR/$lang"
        [ -d "$dir" ] || continue
        for f in ${patterns[$lang]}; do
            if [ -e "$dir/$f" ]; then rm -f "$dir/$f"; removed=$((removed + 1)); fi
        done
    done

    rm -rf "$LANGUAGES_DIR/C#/Bench/bin" "$LANGUAGES_DIR/C#/Bench/obj" "$LANGUAGES_DIR/C#/Bench/out" 2>/dev/null
    rm -rf "$LANGUAGES_DIR/Zig/.zig-cache" "$LANGUAGES_DIR/Zig/zig-cache" "$LANGUAGES_DIR/Zig/zig-out" 2>/dev/null
    # Go's user-wide build cache would turn a rebuild into a bare link, hiding compile time.
    rm -rf "$LANGUAGES_DIR/GO/.gocache" 2>/dev/null
    rm -rf "$LANGUAGES_DIR/Python/__pycache__" 2>/dev/null
    # Nim caches C objects keyed on source only; a compiler bump leaves stale LTO objects.
    rm -rf "$LANGUAGES_DIR/Nim/nimcache" 2>/dev/null

    # dotnet file-based apps cache an apphost outside the repo. Its ELF interpreter
    # is a hard /nix/store glibc path, so a nixpkgs bump + GC leaves the cached
    # binary unrunnable while dotnet still considers the build up to date.
    # Only entries whose assets file points at this repo are removed.
    local runfile entry
    for runfile in "${XDG_DATA_HOME:-$HOME/.local/share}/dotnet/runfile" \
                   "${DOTNET_CLI_HOME:-$HOME}/.dotnet/runfile"; do
        [ -d "$runfile" ] || continue
        for entry in "$runfile"/Program-*/; do
            [ -d "$entry" ] || continue
            if grep -qsF "$LANGUAGES_DIR/C#/Bench/" "$entry/obj/project.assets.json"; then
                rm -rf "$entry"
            fi
        done
    done

    echo -e "${G}✓${N} Cleaned ${removed} artifacts + C#/Zig/Go/Nim/Python caches + dotnet runfile cache"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    clean_artifacts
fi
