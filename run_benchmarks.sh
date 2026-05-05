#!/bin/bash
# Benchmark runner — compiles + runs each language, captures timings, prints summary.
# Usage: ./run_benchmarks.sh [--runs N] [--only LANG1,LANG2]

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LANGUAGES_DIR="$SCRIPT_DIR/languages"
RESULTS_FILE="$SCRIPT_DIR/benchmark_results_$(date +%Y%m%d_%H%M%S).txt"

RUNS=1
ONLY=""

while [ $# -gt 0 ]; do
    case "$1" in
        --runs) RUNS=$2; shift 2 ;;
        --only) ONLY=$2; shift 2 ;;
        -h|--help)
            echo "Usage: $0 [--runs N] [--only Lang1,Lang2,...]"
            exit 0 ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

# Colors
B='\033[1;34m'; G='\033[0;32m'; R='\033[0;31m'; Y='\033[1;33m'; D='\033[2m'; N='\033[0m'

# ----------------------------------------------------------------------------
# Language configuration: name | subdir | binary_command | compile | run | version
# binary_command: PATH command that must exist for lang to be enabled
# compile: empty for interpreted langs
# ----------------------------------------------------------------------------
LANGS=(
    "C|C|gcc|gcc -O3 -march=native -flto -funroll-loops -fomit-frame-pointer bench.c -o bench|./bench|gcc --version | head -n1"
    "Fortran|Fortran|gfortran|gfortran -std=f2023 -O3 -march=native -funroll-loops bench.f90 -o bench|./bench|gfortran --version | head -n1"
    "Ada|Ada|gnatmake|gnatmake -O3 -gnatp -gnatn -funroll-loops -finline-functions -flto -march=native bench.adb|./bench|gnat --version | head -n1"
    "Pascal|Pascal|fpc|fpc -O3 -OoLOOPUNROLL -OoREGVAR -CfAVX2 -Xs bench.pas|./bench|fpc -iV"
    "D|D|ldc2|ldc2 -O3 -release -mcpu=native -flto=full -of=bench bench.d|./bench|ldc2 --version | head -n1"
    "Rust|Rust|rustc|rustc -C opt-level=3 -C lto=fat -C target-cpu=native -C codegen-units=1 -C panic=abort bench.rs -o bench|./bench|rustc --version"
    "Zig|Zig|zig|zig build-exe -OReleaseFast -mcpu=native -lc bench.zig|./bench|zig version"
    "Go|GO|go|GOAMD64=v3 CGO_ENABLED=0 go build -ldflags=\"-s -w\" -trimpath -buildmode=exe bench.go|./bench|go version"
    "Nim|Nim|nim|nim c -d:danger -d:lto --passC:\"-O3\" --passC:\"-flto\" --passC:\"-march=native\" --passC:\"-mtune=native\" --passC:\"-fomit-frame-pointer\" --passC:\"-funroll-loops\" --passL:\"-flto\" bench.nim|./bench|nim --version | head -n1"
    "OCaml|OCaml|ocamlopt|ocamlopt -O3 -unsafe -nodynlink unix.cmxa bench.ml -o bench|./bench|ocamlopt --version"
    "Java|Java|java||java -Xms512m -Xmx2g -XX:+UseG1GC bench.java|java --version | head -n1"
    "Dart|Dart|dart|dart compile exe bench.dart -o bench|./bench|dart --version 2>&1"
    "C#|C#/Bench|dotnet||dotnet run -c Release Program.cs|dotnet --version"
    "JavaScript (Bun)|JS|bun||bun bench.js|bun --version"
    "JavaScript (Node)|JS|node||node bench.js|node --version"
    "Python (PyPy3)|Python|pypy3||pypy3 bench.py|pypy3 --version 2>&1 | head -n1"
    "Python (Python3)|Python|python3||python3 -O bench.py|python3 --version"
    "PHP|Php|php||php -d memory_limit=1G -d opcache.enable_cli=1 -d opcache.jit=tracing -d opcache.jit_buffer_size=256M bench.php|php --version | head -n1"
)

# ----------------------------------------------------------------------------
# Cleanup compiled artifacts
# ----------------------------------------------------------------------------
clean_artifacts() {
    declare -A patterns=(
        [Ada]="bench bench.ali bench.o"
        [C]="bench"
        [D]="bench bench.o"
        [Fortran]="bench bench.o bench.mod"
        [GO]="bench"
        [Java]="bench.class"
        [Nim]="bench"
        [OCaml]="bench bench.cmi bench.cmx bench.o"
        [Pascal]="bench bench.o bench.ppu"
        [Rust]="bench"
        [Zig]="bench bench.o"
        [Dart]="bench bench.exe"
    )
    local removed=0
    for lang in "${!patterns[@]}"; do
        local dir="$LANGUAGES_DIR/$lang"
        [ -d "$dir" ] || continue
        for f in ${patterns[$lang]}; do
            if [ -e "$dir/$f" ]; then rm -f "$dir/$f"; removed=$((removed + 1)); fi
        done
    done
    rm -rf "$LANGUAGES_DIR/C#/Bench/bin" "$LANGUAGES_DIR/C#/Bench/obj" 2>/dev/null
    rm -rf "$LANGUAGES_DIR/Zig/.zig-cache" "$LANGUAGES_DIR/Zig/zig-cache" "$LANGUAGES_DIR/Zig/zig-out" 2>/dev/null
    echo -e "${G}✓${N} Cleaned ${removed} artifacts + C#/Zig caches"
}

# ----------------------------------------------------------------------------
# Single language run
# ----------------------------------------------------------------------------
run_lang() {
    local name=$1 subdir=$2 cmdcheck=$3 compile=$4 run=$5 version=$6
    local dir="$LANGUAGES_DIR/$subdir"

    [ -d "$dir" ] || { echo -e "${D}skip $name (no dir)${N}"; return 0; }
    if ! command -v "$cmdcheck" &>/dev/null; then
        echo -e "${D}skip $name ($cmdcheck not in PATH)${N}"
        return 0
    fi
    if [ -n "$ONLY" ] && [[ ",$ONLY," != *",$name,"* ]]; then return 0; fi

    local ver
    ver=$(eval "$version" 2>&1 | head -n1 || echo "?")
    echo -e "${B}[$name]${N} $ver"
    echo "" >> "$RESULTS_FILE"
    echo "### $name ($ver)" >> "$RESULTS_FILE"

    cd "$dir"

    if [ -n "$compile" ]; then
        local cstart=$(date +%s.%N)
        if eval "$compile" >>"$RESULTS_FILE" 2>&1; then
            local celapsed=$(awk -v s="$cstart" -v e="$(date +%s.%N)" 'BEGIN{printf "%.2f", e - s}')
            echo -e "  ${G}✓${N} compile (${celapsed}s)"
        else
            echo -e "  ${R}✗${N} compile failed (see $RESULTS_FILE)"
            cd "$SCRIPT_DIR"; return 1
        fi
    fi

    for i in $(seq 1 "$RUNS"); do
        echo "" >> "$RESULTS_FILE"
        echo "=== $name - Run $i ===" >> "$RESULTS_FILE"
        local out
        if out=$(eval "$run" 2>&1); then
            echo "$out" >> "$RESULTS_FILE"
            local p fr st so t
            p=$(echo "$out"  | grep -oE 'Found [0-9]+ primes in [0-9.]+ seconds'                 | grep -oE '[0-9.]+ seconds$' | awk '{print $1}')
            fr=$(echo "$out" | grep -oE 'Fibonacci\( *[0-9]+\) = +[0-9]+ in +[0-9.]+ seconds'    | grep -oE '[0-9.]+ seconds$' | awk '{print $1}')
            st=$(echo "$out" | grep -oE 'Strings: total= *[0-9]+ in +[0-9.]+ seconds'            | grep -oE '[0-9.]+ seconds$' | awk '{print $1}')
            mb=$(echo "$out" | grep -oE 'Mandelbrot: checksum= *-?[0-9]+ in +[0-9.]+ seconds'      | grep -oE '[0-9.]+ seconds$' | awk '{print $1}')
            bt=$(echo "$out" | grep -oE 'BinaryTrees: checksum= *-?[0-9]+ in +[0-9.]+ seconds'     | grep -oE '[0-9.]+ seconds$' | awk '{print $1}')
            t=$(echo "$out"  | grep -oE 'Total execution time: [0-9.]+ seconds'                  | grep -oE '[0-9.]+ seconds$' | awk '{print $1}')
            printf "  ${G}✓${N} run %d/%d  ${D}p=%ss fR=%ss str=%ss mb=%ss bt=%ss${N}  ${Y}total=%ss${N}\n" \
                   "$i" "$RUNS" "${p:-?}" "${fr:-?}" "${st:-?}" "${mb:-?}" "${bt:-?}" "${t:-?}"
        else
            echo "$out" >> "$RESULTS_FILE"
            echo -e "  ${R}✗${N} run $i/$RUNS failed"
        fi
    done

    cd "$SCRIPT_DIR"
}

# ----------------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------------
echo -e "${B}===============================================================${N}"
echo -e "${B}  Programming Language Benchmark Runner${N}"
echo -e "${B}===============================================================${N}"
echo "Started:  $(date)"
echo "Runs:     $RUNS per language"
[ -n "$ONLY" ] && echo "Filter:   $ONLY"
echo "Results:  $RESULTS_FILE"
echo ""

clean_artifacts
echo ""

echo "# benchLANG run $(date)" > "$RESULTS_FILE"
echo "# host: $(uname -srm)" >> "$RESULTS_FILE"
echo "# runs per language: $RUNS" >> "$RESULTS_FILE"

for entry in "${LANGS[@]}"; do
    IFS='|' read -r name subdir cmdcheck compile run version <<< "$entry"
    run_lang "$name" "$subdir" "$cmdcheck" "$compile" "$run" "$version"
done

echo ""
echo -e "${B}===============================================================${N}"
echo -e "${B}  All benchmarks complete${N} ($(date))"
echo -e "${B}===============================================================${N}"

if [ -x "$SCRIPT_DIR/analyze_results.sh" ]; then
    "$SCRIPT_DIR/analyze_results.sh" "$RESULTS_FILE"
fi

echo "Re-analyze later:  ./analyze_results.sh $RESULTS_FILE"
