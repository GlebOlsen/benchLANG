#!/bin/bash

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LANGUAGES_DIR="$SCRIPT_DIR/languages"
RESULTS_FILE="$SCRIPT_DIR/benchmark_results_$(date +%Y%m%d_%H%M%S).txt"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "==================================================================="
echo "           Programming Language Benchmark Runner"
echo "==================================================================="
echo ""
echo "Results will be saved to: $RESULTS_FILE"
echo ""

# Helper function to run benchmark
run_benchmark() {
    local lang_name=$1
    local lang_dir=$2
    local compile_cmd=$3
    local run_cmd=$4
    local version_cmd=$5
    local iterations=${6:-3}
    
    echo -e "${BLUE}==================================================================${NC}"
    echo -e "${BLUE}  Running $lang_name Benchmark${NC}"
    echo -e "${BLUE}==================================================================${NC}"
    echo ""
    
    cd "$lang_dir"
    
    # Get and store version
    if [ -n "$version_cmd" ]; then
        echo -e "${YELLOW}Getting version...${NC}"
        echo "Command: $version_cmd"
        local version_info
        version_info=$(eval "$version_cmd" 2>&1 | head -n 1)
        echo "$version_info"
        echo "$lang_name Version: $version_info" >> "$RESULTS_FILE"
        echo ""
    fi
    
    # Compile if compile command is provided
    if [ -n "$compile_cmd" ]; then
        echo -e "${YELLOW}Compiling...${NC}"
        echo "Command: $compile_cmd"
        if eval "$compile_cmd" 2>&1 | tee -a "$RESULTS_FILE"; then
            echo -e "${GREEN}✓ Compilation successful${NC}"
        else
            echo -e "${RED}✗ Compilation failed${NC}"
            echo ""
            return 1
        fi
        echo ""
    fi
    
    # Run benchmark iterations
    for i in $(seq 1 $iterations); do
        echo -e "${GREEN}--- Run $i/$iterations ---${NC}"
        echo "Command: $run_cmd"
        echo ""
        
        echo "=== $lang_name - Run $i ===" >> "$RESULTS_FILE"
        if eval "$run_cmd" 2>&1 | tee -a "$RESULTS_FILE"; then
            echo -e "${GREEN}✓ Run $i completed${NC}"
        else
            echo -e "${RED}✗ Run $i failed${NC}"
        fi
        echo "" >> "$RESULTS_FILE"
        echo ""
        
        if [ $i -lt $iterations ]; then
            sleep 2
            clear
            echo -e "${BLUE}==================================================================${NC}"
            echo -e "${BLUE}  $lang_name Benchmark - Continuing...${NC}"
            echo -e "${BLUE}==================================================================${NC}"
            echo ""
        fi
    done
    
    echo ""
    sleep 2
    clear
    
    cd "$SCRIPT_DIR"
}

# Start benchmarking
echo "Starting benchmarks at $(date)" | tee "$RESULTS_FILE"
echo "" | tee -a "$RESULTS_FILE"

# C Language
if [ -d "$LANGUAGES_DIR/C" ]; then
    run_benchmark "C" \
        "$LANGUAGES_DIR/C" \
        "gcc -O3 -march=native -flto -funroll-loops -fomit-frame-pointer -ffast-math bench.c -o bench" \
        "./bench" \
        "gcc --version"
fi

# C# Language
if [ -d "$LANGUAGES_DIR/C#/Bench" ]; then
    run_benchmark "C#" \
        "$LANGUAGES_DIR/C#/Bench" \
        "" \
        "~/Downloads/dotnet/dotnet run Program.cs" \
        "~/Downloads/dotnet/dotnet --version"
fi

# Java Language
if [ -d "$LANGUAGES_DIR/Java" ]; then
    run_benchmark "Java" \
        "$LANGUAGES_DIR/Java" \
        "/usr/lib/jvm/java-25-openjdk/bin/javac bench.java" \
        "/usr/lib/jvm/java-25-openjdk/bin/java bench" \
        "/usr/lib/jvm/java-25-openjdk/bin/java --version"
fi

# Rust Language
if [ -d "$LANGUAGES_DIR/Rust" ]; then
    run_benchmark "Rust" \
        "$LANGUAGES_DIR/Rust" \
        "rustc -C opt-level=3 -C lto=fat -C target-cpu=native -C codegen-units=1 -C panic=abort bench.rs -o bench" \
        "./bench" \
        "rustc --version"
fi

# Zig Language
if [ -d "$LANGUAGES_DIR/Zig" ]; then
    run_benchmark "Zig" \
        "$LANGUAGES_DIR/Zig" \
        "~/Downloads/zig-x86_64-linux-0.16.0-dev/zig build-exe -OReleaseFast -mcpu=native bench.zig" \
        "./bench" \
        "~/Downloads/zig-x86_64-linux-0.16.0-dev/zig version"
fi

# D Language
if [ -d "$LANGUAGES_DIR/D" ]; then
    run_benchmark "D" \
        "$LANGUAGES_DIR/D" \
        "gdc -O3 -ffast-math -funroll-loops bench.d -o bench" \
        "./bench" \
        "gdc --version"
fi

# Go Language
if [ -d "$LANGUAGES_DIR/GO" ]; then
    run_benchmark "Go" \
        "$LANGUAGES_DIR/GO" \
        "CGO_ENABLED=0 go build -ldflags=\"-s -w\" -trimpath -buildmode=exe bench.go" \
        "./bench" \
        "go version"
fi

# JavaScript (Bun)
if [ -d "$LANGUAGES_DIR/JS" ] && command -v bun &> /dev/null; then
    run_benchmark "JavaScript (Bun)" \
        "$LANGUAGES_DIR/JS" \
        "" \
        "bun bench.js" \
        "bun --version"
fi

# JavaScript (Node)
if [ -d "$LANGUAGES_DIR/JS" ] && command -v node &> /dev/null; then
    run_benchmark "JavaScript (Node)" \
        "$LANGUAGES_DIR/JS" \
        "" \
        "node bench.js" \
        "node --version"
fi

# Python (PyPy)
if [ -d "$LANGUAGES_DIR/Python" ] && command -v pypy3 &> /dev/null; then
    run_benchmark "Python (PyPy3)" \
        "$LANGUAGES_DIR/Python" \
        "" \
        "pypy3 bench.py" \
        "pypy3 --version"
fi

# # Python (CPython)
# if [ -d "$LANGUAGES_DIR/Python" ] && command -v python3 &> /dev/null; then
#     run_benchmark "Python (Python3)" \
#         "$LANGUAGES_DIR/Python" \
#         "" \
#         "python3 bench.py"
# fi

# # PHP Language
# if [ -d "$LANGUAGES_DIR/Php" ] && command -v php &> /dev/null; then
#     run_benchmark "PHP" \
#         "$LANGUAGES_DIR/Php" \
#         "" \
#         "php bench.php"
# fi

# Nim Language
if [ -d "$LANGUAGES_DIR/Nim" ] && command -v nim &> /dev/null; then
    run_benchmark "Nim" \
        "$LANGUAGES_DIR/Nim" \
        "nim c -d:release -d:lto --passC:\"-O3\" --passC:\"-flto\" --passC:\"-march=native\" --passC:\"-mtune=native\" --passL:\"-flto\" bench.nim" \
        "./bench" \
        "nim --version"
fi

# OCaml Language
if [ -d "$LANGUAGES_DIR/OCaml" ] && command -v ocamlopt &> /dev/null; then
    run_benchmark "OCaml" \
        "$LANGUAGES_DIR/OCaml" \
        "ocamlopt -O3 -nodynlink unix.cmxa bench.ml -o bench" \
        "./bench" \
        "ocamlopt --version"
fi

# Ada Language
if [ -d "$LANGUAGES_DIR/Ada" ] && command -v gnatmake &> /dev/null; then
    run_benchmark "Ada" \
        "$LANGUAGES_DIR/Ada" \
        "gnatmake -O3 -funroll-loops -finline-functions -flto -march=native bench.adb" \
        "./bench" \
        "gnat --version"
fi

# Fortran Language
if [ -d "$LANGUAGES_DIR/Fortran" ] && command -v gfortran &> /dev/null; then
    run_benchmark "Fortran" \
        "$LANGUAGES_DIR/Fortran" \
        "gfortran -O3 -march=native -flto -funroll-loops -ffast-math bench.f90 -o bench" \
        "./bench" \
        "gfortran --version"
fi

# Pascal Language
if [ -d "$LANGUAGES_DIR/Pascal" ] && command -v fpc &> /dev/null; then
    run_benchmark "Pascal" \
        "$LANGUAGES_DIR/Pascal" \
        "fpc -O3 bench.pas" \
        "./bench" \
        "fpc -i"
fi

# Summary
echo -e "${BLUE}==================================================================${NC}"
echo -e "${BLUE}  All Benchmarks Complete!${NC}"
echo -e "${BLUE}==================================================================${NC}"
echo ""
echo "Finished at $(date)"
echo "Results saved to: $RESULTS_FILE"
echo ""
echo "To analyze results, you can use:"
echo "  cat $RESULTS_FILE"
echo "  grep -E \"(Found|Fibonacci|Matrix|Sorting|String|Total)\" $RESULTS_FILE"
echo ""
