#!/bin/bash
# Compiles and runs every language, recording compile time, per-workload wall
# time, process CPU time, peak RSS and native binary size.
# Usage: ./run_benchmarks.sh [--runs N] [--only Lang1,Lang2] [--compile-only]

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LANGUAGES_DIR="$SCRIPT_DIR/languages"
RESULTS_FILE="$SCRIPT_DIR/benchmark_results_$(date +%Y%m%d_%H%M%S).txt"

RUNS=1
ONLY=""
COMPILE_ONLY=0

while [ $# -gt 0 ]; do
    case "$1" in
        --runs) [ $# -ge 2 ] || { echo "--runs needs a number"; exit 1; }; RUNS=$2; shift 2 ;;
        --only) [ $# -ge 2 ] || { echo "--only needs a comma-separated list"; exit 1; }; ONLY=$2; shift 2 ;;
        --compile-only) COMPILE_ONLY=1; shift ;;
        -h|--help) echo "Usage: $0 [--runs N] [--only Lang1,Lang2,...] [--compile-only]"; exit 0 ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

[[ "$RUNS" =~ ^[1-9][0-9]*$ ]] || { echo "--runs must be a positive integer, got '$RUNS'"; exit 1; }
FAILED=0

B='\033[1;34m'; G='\033[0;32m'; R='\033[0;31m'; Y='\033[1;33m'; D='\033[2m'; N='\033[0m'

TIME_BIN=$(type -P time) || { echo "GNU time binary not in PATH (nix develop provides it)"; exit 1; }

# ----------------------------------------------------------------------------
# name | subdir | required command | compile | run | native binary | version
# version is last because it may contain pipes.
# ----------------------------------------------------------------------------
LANGS=(
    "C|C|gcc|gcc -O3 -march=native -flto -funroll-loops -ffp-contract=off -s bench.c -o bench|./bench|bench|gcc --version | head -n1"
    "C++|C++|g++|g++ -std=c++20 -O3 -march=native -flto -funroll-loops -ffp-contract=off -s bench.cpp -o bench|./bench|bench|g++ --version | head -n1"
    "Fortran|Fortran|gfortran|gfortran -std=f2023 -O3 -march=native -flto -funroll-loops -ffp-contract=off -s bench.f90 -o bench|./bench|bench|gfortran --version | head -n1"
    "Ada|Ada|gnatmake|gnatmake -O3 -gnatp -gnatn -march=native -flto -funroll-loops -ffp-contract=off bench.adb -largs -s|./bench|bench|gnat --version | head -n1"
    "Pascal|Pascal|fpc|fpc -O3 -OoLOOPUNROLL -OoREGVAR -CpCOREAVX2 -CfAVX2 -Xs bench.pas|./bench|bench|fpc -iV"
    "D|D|ldc2|ldc2 -O3 -release -mcpu=native -flto=full -fp-contract=off -L-s -of=bench bench.d|./bench|bench|ldc2 --version | head -n1"
    "Rust|Rust|rustc|rustc -C opt-level=3 -C lto=fat -C target-cpu=native -C codegen-units=1 -C panic=abort -C strip=symbols bench.rs -o bench|./bench|bench|rustc --version"
    "Zig|Zig|zig|zig build-exe -OReleaseFast -mcpu=native -fstrip -lc bench.zig|./bench|bench|zig version"
    "Go|GO|go|GOCACHE=\$PWD/.gocache GOAMD64=v3 CGO_ENABLED=0 go build -ldflags='-s -w' -trimpath -o bench bench.go|./bench|bench|go version"
    "Nim|Nim|nim|nim c --hints:off --nimcache:nimcache -d:danger -d:lto --panics:on --passC:-march=native --passC:-ffp-contract=off --passL:-s bench.nim|./bench|bench|nim --version | head -n1"
    "OCaml|OCaml|ocamlopt|ocamlopt -O3 -unsafe -inline 200 -nodynlink monotonic.c bench.ml -o bench -ccopt -s|./bench|bench|ocamlopt --version"
    "Java|Java|java|javac bench.java|java bench||java --version | head -n1"
    "Dart|Dart|dart|dart compile exe bench.dart -o bench -S bench.sym|./bench|bench|dart --version 2>&1"
    "C#|C#/Bench|dotnet|dotnet build -c Release -o out Program.cs|dotnet out/Program.dll||dotnet --version"
    "JavaScript (Bun)|JS|bun||bun bench.js||bun --version"
    "JavaScript (Node)|JS|node||node bench.js||node --version"
    "Python (PyPy3)|Python|pypy3||pypy3 bench.py||pypy3 --version 2>&1 | head -n1"
    "Python (Python3)|Python|python3||python3 bench.py||python3 --version"
    "PHP|Php|php||php -d memory_limit=1G -d opcache.enable_cli=1 -d opcache.jit=tracing -d opcache.jit_buffer_size=256M bench.php||php --version | head -n1"
)

. "$SCRIPT_DIR/clean.sh"

if [ -n "$ONLY" ]; then
    IFS=',' read -ra only_names <<< "$ONLY"
    for o in "${only_names[@]}"; do
        found=0
        for entry in "${LANGS[@]}"; do [ "${entry%%|*}" = "$o" ] && found=1; done
        [ "$found" = 1 ] || { echo "Unknown language in --only: '$o'"; exit 1; }
    done
fi

log() { printf '%s\n' "$*" >> "$RESULTS_FILE"; }
log_comment() { sed 's/^/# /' >> "$RESULTS_FILE"; }

run_lang() {
    local name=$1 subdir=$2 cmdcheck=$3 compile=$4 run=$5 binary=$6 version=$7
    local dir="$LANGUAGES_DIR/$subdir"

    if [ -n "$ONLY" ] && [[ ",$ONLY," != *",$name,"* ]]; then return 0; fi
    if [ "$COMPILE_ONLY" = 1 ] && [ -z "$compile" ]; then return 0; fi
    [ -d "$dir" ] || { echo -e "${D}skip $name (no dir)${N}"; return 0; }
    command -v "$cmdcheck" &>/dev/null || { echo -e "${D}skip $name ($cmdcheck not in PATH)${N}"; return 0; }

    local ver
    ver=$(eval "$version" 2>&1 | head -n1)
    echo -e "${B}[$name]${N} $ver"
    cd "$dir" || return 1

    local csecs=""
    if [ -n "$compile" ]; then
        local cstart cout
        cstart=$(date +%s.%N)
        if cout=$(eval "$compile" 2>&1); then
            csecs=$(awk -v s="$cstart" -v e="$(date +%s.%N)" 'BEGIN{printf "%.3f", e-s}')
            echo -e "  ${G}ok${N} compile (${csecs}s)"
        else
            printf 'compile failed: %s\n%s\n' "$name" "$cout" | log_comment
            echo -e "  ${R}fail${N} compile (see $RESULTS_FILE)"
            FAILED=$((FAILED + 1))
            cd "$SCRIPT_DIR"; return 1
        fi
    fi

    local size=""
    if [ -n "$binary" ] && [ -f "$binary" ]; then size=$(stat -c %s "$binary"); fi
    printf 'LANG\t%s\t%s\t%s\t%s\n' "$name" "$ver" "$size" "$csecs" >> "$RESULTS_FILE"
    if [ "$COMPILE_ONLY" = 1 ]; then cd "$SCRIPT_DIR"; return 0; fi

    local tf out i results
    tf=$(mktemp)
    for i in $(seq 1 "$RUNS"); do
        if ! out=$("$TIME_BIN" -f '%e %U %S %M' -o "$tf" bash -c "$run" 2>&1); then
            printf 'run failed: %s\n%s\n' "$name" "$out" | log_comment
            echo -e "  ${R}fail${N} run $i/$RUNS (see $RESULTS_FILE)"
            FAILED=$((FAILED + 1))
            continue
        fi
        # A run counts only if it printed exactly one numeric line per workload.
        if ! results=$(awk -v lang="$name" -v run="$i" '
                NF == 3 && $1 ~ /^(primes|fib|strings|mandelbrot|binarytrees)$/ &&
                $2 ~ /^-?[0-9]+$/ && $3 ~ /^[0-9]+(\.[0-9]+)?$/ && !seen[$1]++ {
                    printf "RESULT\t%s\t%d\t%s\t%s\t%s\n", lang, run, $1, $2, $3; n++
                }
                END { exit (n == 5 ? 0 : 1) }' <<< "$out"); then
            printf 'run produced incomplete output: %s\n%s\n' "$name" "$out" | log_comment
            echo -e "  ${R}fail${N} run $i/$RUNS incomplete output (see $RESULTS_FILE)"
            FAILED=$((FAILED + 1))
            continue
        fi
        local wall user sys rss
        read -r wall user sys rss < "$tf"
        {
            printf '%s\n' "$results"
            printf 'RUSAGE\t%s\t%d\t%s\t%s\t%s\t%s\n' "$name" "$i" "$wall" "$user" "$sys" "$rss"
        } >> "$RESULTS_FILE"
        awk -F'\t' -v i="$i" -v runs="$RUNS" -v wall="$wall" -v user="$user" -v sys="$sys" -v rss="$rss" -v G="$G" -v Y="$Y" -v D="$D" -v N="$N" '
            { t[$4] = $6; sum += $6 }
            END {
                printf "  %sok%s run %d/%d  %sprimes=%s fib=%s strings=%s mandel=%s trees=%s%s  %ssum=%.3fs%s wall=%ss cpu=%.2fx rss=%dMiB\n",
                    G, N, i, runs, D, t["primes"], t["fib"], t["strings"], t["mandelbrot"], t["binarytrees"], N,
                    Y, sum, N, wall, (wall > 0 ? (user + sys) / wall : 0), rss / 1024
            }' <<< "$results"
    done
    rm -f "$tf"
    cd "$SCRIPT_DIR"
}

echo -e "${B}===============================================================${N}"
echo -e "${B}  benchLANG runner${N}"
echo -e "${B}===============================================================${N}"
echo "Started:  $(date)"
if [ "$COMPILE_ONLY" = 1 ]; then echo "Mode:     compile only"; else echo "Runs:     $RUNS per language"; fi
[ -n "$ONLY" ] && echo "Filter:   $ONLY"
echo "Results:  $RESULTS_FILE"
echo ""

clean_artifacts
echo ""

{
    echo "# benchLANG run $(date)"
    echo "# host: $(uname -srm)"
    echo "# cpu: $(grep -m1 'model name' /proc/cpuinfo | sed 's/.*: //')"
    if [ "$COMPILE_ONLY" = 1 ]; then echo "# compile only, no workloads run"; else echo "# runs per language: $RUNS"; fi
    echo "# LANG   name  version  native_binary_bytes  compile_s"
    echo "# RESULT name  run  workload  checksum  seconds"
    echo "# RUSAGE name  run  wall_s  user_s  sys_s  max_rss_kb"
} > "$RESULTS_FILE"

for entry in "${LANGS[@]}"; do
    IFS='|' read -r name subdir cmdcheck compile run binary version <<< "$entry"
    run_lang "$name" "$subdir" "$cmdcheck" "$compile" "$run" "$binary" "$version"
done

echo ""
echo -e "${B}===============================================================${N}"
if [ "$COMPILE_ONLY" = 1 ]; then echo -e "${B}  All compiles complete${N} ($(date))"; else echo -e "${B}  All benchmarks complete${N} ($(date))"; fi
echo -e "${B}===============================================================${N}"

if [ -x "$SCRIPT_DIR/analyze_results.sh" ]; then
    "$SCRIPT_DIR/analyze_results.sh" "$RESULTS_FILE" || FAILED=$((FAILED + 1))
fi
echo "Re-analyze later:  ./analyze_results.sh $RESULTS_FILE"
[ "$FAILED" -eq 0 ] || { echo "$FAILED failure(s), see $RESULTS_FILE"; exit 1; }
