# benchLANG: Programming Language Benchmark 2026

Reproducible runtime benchmark: 20 languages (22 runtimes), 6 identical workloads, toolchains pinned with Nix. Measures runtime, memory usage, binary size and compile time.

## Results

Runtime in seconds, average of 2 runs per language, 20 October 2026, CPU locked at 3.5 GHz.
Binary and Compile show `-` for languages without a native build (bytecode, JIT or interpreter).

| Language | Total | vs fastest | Memory (MiB) | Binary (KiB) | Compile (s) | Primes | Fib | Strings | Mandelbrot | Trees | k-nucleotide |
|---|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| C | 3.90 | 1.00x | 24 | 34 | 0.68 | **0.75** | 0.65 | **0.54** | **0.55** | 0.84 | **0.57** |
| C++ | 4.37 | 1.12x | 20 | 42 | 2.59 | **0.75** | 0.65 | 0.55 | **0.55** | 0.94 | 0.94 |
| Fortran | 4.53 | 1.16x | 19 | 42 | 0.81 | **0.75** | 0.66 | 0.79 | **0.55** | 0.85 | 0.94 |
| Nim | 4.53 | 1.16x | 76 | 78 | 2.72 | **0.75** | 0.69 | 0.56 | **0.55** | 0.37 | 1.62 |
| Rust | 4.59 | 1.18x | 21 | 357 | 4.36 | **0.75** | 1.01 | 0.59 | **0.55** | 0.91 | 0.77 |
| D | 4.88 | 1.25x | 50 | 935 | 3.26 | **0.75** | 1.14 | 0.59 | **0.55** | 1.16 | 0.69 |
| C# | 5.29 | 1.36x | 108 | - | - | **0.75** | 1.57 | 0.58 | 0.56 | 0.41 | 1.44 |
| Java | 5.58 | 1.43x | 381 | - | - | **0.75** | 1.58 | 0.85 | 0.57 | **0.14** | 1.68 |
| Zig | 5.65 | 1.45x | 23 | 348 | 4.88 | **0.75** | 1.87 | 1.10 | **0.55** | 0.72 | 0.65 |
| Go | 6.02 | 1.55x | 37 | 1512 | 2.36 | **0.75** | 2.32 | 0.83 | 0.56 | 0.60 | 0.96 |
| Ada | 6.18 | 1.59x | 26 | 578 | 3.83 | **0.75** | **0.62** | 0.86 | **0.55** | 0.91 | 2.50 |
| OCaml | 7.98 | 2.05x | 41 | 1356 | 0.29 | 0.88 | 1.87 | 1.36 | 0.57 | 0.28 | 3.01 |
| Dart | 8.55 | 2.20x | 81 | 5857 | 1.05 | 0.81 | 3.20 | 1.65 | 0.57 | 0.22 | 2.10 |
| JS (Bun) | 8.89 | 2.28x | 271 | - | - | 0.76 | 2.80 | 1.47 | 0.57 | 0.30 | 3.00 |
| Swift | 9.38 | 2.41x | 37 | 39 | 1.39 | **0.75** | 2.07 | 1.80 | 0.56 | 1.59 | 2.61 |
| JS (Node) | 11.86 | 3.04x | 214 | - | - | 0.76 | 4.44 | 1.57 | 0.56 | 0.57 | 3.95 |
| Python (PyPy) | 12.53 | 3.22x | 157 | - | - | 0.93 | 5.16 | 1.49 | 0.60 | 1.67 | 2.68 |
| PHP | 18.05 | 4.63x | 131 | - | - | 0.93 | 8.80 | 2.11 | 1.10 | 3.24 | 1.88 |
| Haskell | 18.68 | 4.80x | 58 | 1324 | 1.09 | 0.76 | 2.02 | 1.74 | 0.77 | 0.17 | 13.22 |
| Pascal | 19.14 | 4.91x | 23 | 1196 | 0.90 | 0.90 | 2.92 | 4.81 | 1.55 | 0.71 | 8.25 |
| Ruby | 30.26 | 7.77x | 65 | - | - | 1.60 | 5.04 | 4.89 | 9.31 | 1.36 | 8.06 |
| Python (CPython) | 132.55 | 34.03x | 63 | - | - | 20.43 | 53.20 | 7.51 | 33.73 | 9.89 | 7.79 |

## Methodology

* Every language runs the same workloads, written the idiomatic way, one file each.
* Inputs are compile-time constants. If a compiler folds a workload away, that is a result.
* Each workload prints `name checksum seconds`. Different checksums invalidate the ranking.
* Ranking is the sum of all workload times.
* Compiled languages use their fastest release flags. Array bounds checks stay on everywhere, because Rust, Java and C# cannot turn them off; C has none. Swift and Zig cannot keep bounds checks without overflow checks, so they keep both.
* Managed runtimes use default settings, JIT warm-up included. PHP (OPcache) and Ruby (YJIT) switch their JIT on, as in production.
* No FMA anywhere, so floating-point results match bit for bit.
* Memory usage is the peak of the whole process. Binary size is the stripped executable, without shared runtime libraries (libstdc++, libgfortran, libswiftCore). Compile time is a clean native build. Zig can add about 2 s on a cold cache.
* Machine: Ryzen 9 5900X locked at 3.5 GHz, 48 GB DDR4-3600 CL16, Arch Linux with i3 and background services stopped.
* Compiles and benchmarks run pinned to the second CCD (CPUs 6-11, 18-23). The runner and GNU `time` stay on the first core (CPUs 0 and 12).

## Workloads

* **Primes:** trial division of every number below 8,000,000. Integer division.
* **Fibonacci:** naive recursive fib(43), 1.4 billion calls. Function calls.
* **Strings:** 1.2M rounds. Each round reverses one of 19 words, then compares every word against the originals. String building and equality.
* **Mandelbrot:** 2048x2048 pixels, up to 256 iterations each. Floating point.
* **Trees:** build, check and free millions of binary trees (depth 4 to 17). Allocation and GC. Native code frees memory inside the timer, GC runtimes collect whenever they like.
* **k-nucleotide:** count every 1, 2, 3, 4, 6, 12 and 18-letter substring of a generated 6M-letter DNA string in the standard hash map. Sort the 1 and 2-letter counts, look up one fixed sequence for the longer ones. Hash maps and substrings.

C and Fortran have no standard hash map, so they share one simple open-addressing table. Haskell ships only a tree map (`Data.Map`).

## Run it

```bash
sudo cpupower frequency-set -g performance
sudo cpupower frequency-set --max 3500MHz
sudo cpupower frequency-set --min 3500MHz

nix develop                          # all toolchains, pinned
./run_benchmarks.sh                  # every language, 1 run each
./run_benchmarks.sh --runs 3         # 3 runs each, averaged
./run_benchmarks.sh --only C,Rust,Zig
./run_benchmarks.sh --compile-only   # compile times only
./run_benchmarks.sh --cpus 6-11      # pick the benchmark CPUs yourself
./analyze_results.sh                 # summary of the latest results file
./analyze_results.sh --markdown      # the Results table above
./clean.sh                           # remove build artifacts and caches
```

Results land in `benchmark_results_<timestamp>.txt`.

## Toolchains

All from nixpkgs-unstable, no overlays, no vendored binaries.

| Language | Version |
|---|---|
| C, C++, Fortran, Ada | GCC 16.2.0 |
| D | LDC 1.42.0 |
| Rust | 1.99.0 |
| Zig | 0.17.0 |
| Go | 1.27.2 |
| Nim | 2.2.12 |
| OCaml | 5.5.1 |
| Pascal | FPC 3.2.2 |
| Swift | 6.3.3 |
| Haskell | GHC 9.14.1 |
| Java | OpenJDK 27 (Temurin) |
| Dart | 3.13.0 |
| C# | .NET SDK 11.0.100-rc.1 |
| JS | Bun 1.4.2, Node 26.12.0 |
| PHP | 8.5.11 |
| Python | CPython 3.15.0, PyPy 7.3.20 |
| Ruby | 4.0.7 |

| Language | Build / run |
|---|---|
| C | `gcc -std=c23 -O3 -march=native -flto -funroll-loops -ffp-contract=off -s` |
| C++ | `g++ -std=c++23 -O3 -march=native -flto -funroll-loops -ffp-contract=off -D_GLIBCXX_ASSERTIONS -s` |
| Fortran | `gfortran -std=f2023 -O3 -march=native -flto -funroll-loops -ffp-contract=off -fcheck=bounds -s` |
| Ada | `gnatmake -gnat2022 -O3 -gnato0 -gnatn -march=native -flto -funroll-loops -ffp-contract=off -largs -s` |
| Pascal | `fpc -O3 -OoLOOPUNROLL -OoREGVAR -CpCOREAVX2 -CfAVX2 -Cr -Xs` |
| D | `ldc2 -O3 -release -boundscheck=on -mcpu=native -flto=full -fp-contract=off -L-s` |
| Rust | `rustc --edition 2024 -C opt-level=3 -C lto=fat -C target-cpu=native -C codegen-units=1 -C panic=abort -C strip=symbols` |
| Zig | `zig build-exe -OReleaseSafe -mcpu=native -fstrip -lc` |
| Go | `GOAMD64=v3 CGO_ENABLED=0 go build -ldflags='-s -w' -trimpath` |
| Nim | `nim c -d:danger --boundChecks:on -d:lto --panics:on --passC:-march=native --passC:-funroll-loops --passC:-ffp-contract=off --passL:-s` |
| OCaml | `ocamlopt -inline 200 -nodynlink monotonic.c -ccopt -s` |
| Swift | `swiftc -swift-version 6 -O -wmo -Xcc -march=native -Xlinker -s` |
| Haskell | `ghc -O2 -msse4.2 -mbmi2 -mavx2 -optl-s` |
| Java | `javac bench.java`, then `java bench` |
| Dart | `dart compile exe -S bench.sym` |
| C# | `dotnet build -c Release -o out Program.cs`, then `dotnet out/Program.dll` |
| JS | `bun bench.js` / `node bench.js` |
| PHP | `php -d opcache.enable_cli=1 -d opcache.jit=tracing -d opcache.jit_buffer_size=256M` |
| Python | `python3 bench.py` / `pypy3 bench.py` |
| Ruby | `ruby --yjit bench.rb` |

Exact commands, including cache paths, are in `run_benchmarks.sh`.
