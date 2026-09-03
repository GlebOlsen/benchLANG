# benchLANG: Programming Language Benchmark 2026

benchLANG is a reproducible cross-language runtime benchmark: 19 languages, five identical workloads, pinned Nix toolchains. Records runtime, peak memory and binary size.

**Purpose:**

Find which programming language is fastest in runtime across identical tasks.

## **Latest results:**

Results from September 2026, one run per language on a Ryzen 9 5900X locked at 3.5 GHz.

## **Methodology:**

Every language runs the same five workloads, written the idiomatic way, one file each. Ranked by summed in-program wall time. GNU `time` adds whole-process CPU time, peak RSS and the runner records stripped binary size.

* Inputs are compile-time constants. A workload the compiler folds away shows up as near-zero time. That is a result, not a bug.
* Each workload prints `name checksum seconds` from a monotonic clock. The analyzer marks the ranking invalid if checksums differ.
* FMA contraction is off everywhere, so Mandelbrot is bit-identical.
* Compiled languages use their fastest release mode, runtime checks off where the compiler allows. Managed runtimes keep their mandated checks, default settings, JIT warm-up inside the timed region.
* `CPUx` = (user+sys)/wall, above 1.0 means extra runtime threads (GC, JIT).

**Workloads:**
* Primes: trial-division primality for every integer below 20,000,000
* Fibonacci: recursive Fibonacci(45)
* Strings: 5M iterations of 19x19 word equality on a sentence split at spaces
* Mandelbrot: 4096x4096 grid, 256 iterations/pixel. FP throughput + branch prediction
* Binary trees: CLBG-style alloc/traverse (depths 4..18). Allocator + GC + pointer chase, native code frees inside the timer, GC runtimes collect when they like

**PC specs:**
* Arch i3-wm (killed most background services apart from kernel and WM)
* Ryzen 9 5900X, 48 GB RAM, DDR4-3600 CL16

**Computer power mode:**

`sudo cpupower frequency-set -g performance`
```
sudo cpupower frequency-set --max 3500MHz
sudo cpupower frequency-set --min 3500MHz
```
**(This makes the CPU run at 3.5 GHz.)**
<br/>

## **Reproducible toolchain (Nix):**

```bash
nix develop                   # enter shell with all toolchains pinned
./run_benchmarks.sh           # full sweep, 1 run/lang
./run_benchmarks.sh --runs 3  # 3 runs/lang, averaged in summary
./run_benchmarks.sh --only C,Rust,Zig
./analyze_results.sh          # re-print summary from latest results file
./clean.sh                    # remove build artifacts and the dotnet runfile cache
```

Results land in `benchmark_results_<timestamp>.txt` (tab-separated `LANG`, `RESULT`, `RUSAGE` lines). Each program also runs standalone.

## **Software versions (current nix-pinned):**

| Language | Compiler / Runtime | Source |
|---|---|---|
| C / C++ / Fortran / Ada | GCC 16.2.0 (gcc / g++ / gfortran / gnat) | nixpkgs-unstable |
| D | LDC 1.42.0 | nixpkgs-unstable |
| Go | 1.26.7 | nixpkgs-unstable |
| Rust | 1.97.1 | nixpkgs-unstable |
| Zig | 0.16.0 | nixpkgs-unstable |
| Pascal | FPC 3.2.2 | nixpkgs-unstable |
| OCaml | 5.4.1 | nixpkgs-unstable |
| Java | OpenJDK 25.0.4 | nixpkgs-unstable |
| Dart | 3.13.0 | nixpkgs-unstable |
| Nim | 2.2.10 | nixpkgs-unstable |
| C# | .NET SDK 11.0.100-preview.7 | nixpkgs-unstable |
| JS (Bun) | 1.3.13 | nixpkgs-unstable |
| JS (Node) | 26.8.1 | nixpkgs-unstable |
| PHP | 8.5.9 (with OPcache JIT) | nixpkgs-unstable |
| Python (CPython) | 3.14.7 | nixpkgs-unstable |
| Python (PyPy3) | 7.3.20 (Python 3.11.13) | nixpkgs-unstable |

Everything comes from nixpkgs-unstable, no overlays, no vendored binaries. The dev shell also provides GNU `time`, which the runner requires.

## **Build and run commands:**

| Language | Command |
|---|---|
| **C** | `gcc -O3 -march=native -flto -funroll-loops -ffp-contract=off -s` |
| **C++** | `g++ -std=c++20 -O3 -march=native -flto -funroll-loops -ffp-contract=off -s` |
| **Fortran** | `gfortran -std=f2023 -O3 -march=native -flto -funroll-loops -ffp-contract=off -s` |
| **Ada** | `gnatmake -O3 -gnatp -gnatn -march=native -flto -funroll-loops -ffp-contract=off -largs -s` |
| **Pascal** | `fpc -O3 -OoLOOPUNROLL -OoREGVAR -CpCOREAVX2 -CfAVX2 -Xs` |
| **D (LDC)** | `ldc2 -O3 -release -mcpu=native -flto=full -fp-contract=off -L-s` |
| **Rust** | `rustc -C opt-level=3 -C lto=fat -C target-cpu=native -C codegen-units=1 -C panic=abort -C strip=symbols` |
| **Zig** | `zig build-exe -OReleaseFast -mcpu=native -fstrip -lc` |
| **Go** | `GOAMD64=v3 CGO_ENABLED=0 go build -ldflags='-s -w' -trimpath` |
| **Nim** | `nim c --nimcache:nimcache -d:danger -d:lto --panics:on --passC:-march=native --passC:-ffp-contract=off --passL:-s` |
| **OCaml** | `ocamlopt -O3 -unsafe -inline 200 -nodynlink monotonic.c -ccopt -s` (C stub: stdlib has no monotonic clock) |
| **Java** | `javac bench.java` then `java bench` (default heap, default GC) |
| **Dart** | `dart compile exe -S bench.sym` (AOT, `-S` strips the snapshot, runtime stays embedded) |
| **C#** | `dotnet build -c Release -o out Program.cs` then `dotnet out/Program.dll` |
| **PHP** | `php -d opcache.enable_cli=1 -d opcache.jit=tracing -d opcache.jit_buffer_size=256M` |
| **Python (CPython)** | `python3` |
| **Python (PyPy3)** | `pypy3` (JIT default) |
| **JS (Bun / Node)** | direct interpret (JIT default) |

> `-ffp-contract=off` and the explicit `float64()` rounding in `bench.go` keep every language on the same IEEE result. Nim `--panics:on` = Rust `-C panic=abort`. PHP OPcache JIT is the standard prod config.

<br/>
<a id="results"></a>

## **Results:**

Results are from 3 September 2026 (one run per language). Peak RSS is whole-process peak resident memory from GNU `time`. Binary size is the stripped native executable, shown as - for languages that run on a separate runtime (JVM, .NET, Bun, Node, PHP, Python).
<table>
<tbody>
    <th>Language</th>
    <th>Total Runtime</th>
    <th>Factor of "slowness"</th>
    <th>Peak RSS</th>
    <th>Binary Size</th>
    <th>Primes</th>
    <th>Fibonacci</th>
    <th>String Operations</th>
    <th>Mandelbrot</th>
    <th>Binary Trees</th>
  <tr>
    <td>C<br/>(GCC 16.2.0)</td>
    <td>9.762 sec</td>
    <td>1.00x</td>
    <td>33.3 MiB</td>
    <td>26 KiB</td>
    <td>2.725 sec</td>
    <td>1.694 sec</td>
    <td>2.132 sec</td>
    <td>2.201 sec</td>
    <td>1.010 sec</td>
  </tr>
  <tr>
    <td>C++<br/>(GCC 16.2.0)</td>
    <td>9.984 sec</td>
    <td>1.02x</td>
    <td>35.4 MiB</td>
    <td>30 KiB</td>
    <td>2.725 sec</td>
    <td>1.721 sec</td>
    <td>2.190 sec</td>
    <td>2.201 sec</td>
    <td>1.147 sec</td>
  </tr>
  <tr>
    <td>Nim<br/>(2.2.10)</td>
    <td>10.298 sec</td>
    <td>1.05x</td>
    <td>51.5 MiB</td>
    <td>46 KiB</td>
    <td>2.725 sec</td>
    <td>1.716 sec</td>
    <td>2.804 sec</td>
    <td>2.244 sec</td>
    <td>0.809 sec</td>
  </tr>
  <tr>
    <td>Ada<br/>(GNAT 16.2.0)</td>
    <td>10.306 sec</td>
    <td>1.06x</td>
    <td>33.7 MiB</td>
    <td>398 KiB</td>
    <td>2.726 sec</td>
    <td>1.666 sec</td>
    <td>2.603 sec</td>
    <td>2.202 sec</td>
    <td>1.109 sec</td>
  </tr>
  <tr>
    <td>Zig<br/>(0.16.0)</td>
    <td>10.737 sec</td>
    <td>1.10x</td>
    <td>33.7 MiB</td>
    <td>236 KiB</td>
    <td>2.722 sec</td>
    <td>3.181 sec</td>
    <td>1.504 sec</td>
    <td>2.211 sec</td>
    <td>1.119 sec</td>
  </tr>
  <tr>
    <td>Fortran<br/>(GCC 16.2.0)</td>
    <td>10.915 sec</td>
    <td>1.12x</td>
    <td>34.4 MiB</td>
    <td>26 KiB</td>
    <td>2.723 sec</td>
    <td>1.701 sec</td>
    <td>3.305 sec</td>
    <td>2.200 sec</td>
    <td>0.986 sec</td>
  </tr>
  <tr>
    <td>Rust<br/>(1.97.1)</td>
    <td>11.767 sec</td>
    <td>1.21x</td>
    <td>34.0 MiB</td>
    <td>349 KiB</td>
    <td>2.724 sec</td>
    <td>3.179 sec</td>
    <td>2.621 sec</td>
    <td>2.210 sec</td>
    <td>1.033 sec</td>
  </tr>
  <tr>
    <td>C#<br/>(.NET 11.0.100-preview.7)</td>
    <td>11.914 sec</td>
    <td>1.22x</td>
    <td>122.1 MiB</td>
    <td>-</td>
    <td>2.726 sec</td>
    <td>3.793 sec</td>
    <td>2.235 sec</td>
    <td>2.229 sec</td>
    <td>0.931 sec</td>
  </tr>
  <tr>
    <td>Java<br/>(OpenJDK 25.0.4)</td>
    <td>13.536 sec</td>
    <td>1.39x</td>
    <td>987.8 MiB</td>
    <td>-</td>
    <td>2.730 sec</td>
    <td>4.109 sec</td>
    <td>4.075 sec</td>
    <td>2.275 sec</td>
    <td>0.347 sec</td>
  </tr>
  <tr>
    <td>D<br/>(LDC 1.42.0)</td>
    <td>13.662 sec</td>
    <td>1.40x</td>
    <td>97.6 MiB</td>
    <td>914 KiB</td>
    <td>2.723 sec</td>
    <td>2.979 sec</td>
    <td>2.351 sec</td>
    <td>2.208 sec</td>
    <td>3.401 sec</td>
  </tr>
  <tr>
    <td>Go<br/>(1.26.7)</td>
    <td>15.366 sec</td>
    <td>1.57x</td>
    <td>60.4 MiB</td>
    <td>1564 KiB</td>
    <td>2.726 sec</td>
    <td>6.075 sec</td>
    <td>2.532 sec</td>
    <td>2.237 sec</td>
    <td>1.796 sec</td>
  </tr>
  <tr>
    <td>OCaml<br/>(5.4.1)</td>
    <td>16.233 sec</td>
    <td>1.66x</td>
    <td>89.7 MiB</td>
    <td>1039 KiB</td>
    <td>3.200 sec</td>
    <td>4.897 sec</td>
    <td>5.000 sec</td>
    <td>2.271 sec</td>
    <td>0.865 sec</td>
  </tr>
  <tr>
    <td>JS (Bun)<br/>(1.3.13)</td>
    <td>16.732 sec</td>
    <td>1.71x</td>
    <td>336.1 MiB</td>
    <td>-</td>
    <td>2.759 sec</td>
    <td>7.735 sec</td>
    <td>3.129 sec</td>
    <td>2.293 sec</td>
    <td>0.816 sec</td>
  </tr>
  <tr>
    <td>Dart<br/>(3.13.0 AOT)</td>
    <td>20.754 sec</td>
    <td>2.13x</td>
    <td>74.6 MiB</td>
    <td>5617 KiB</td>
    <td>2.963 sec</td>
    <td>8.135 sec</td>
    <td>6.523 sec</td>
    <td>2.268 sec</td>
    <td>0.865 sec</td>
  </tr>
  <tr>
    <td>JS (Node)<br/>(v26.8.1)</td>
    <td>20.973 sec</td>
    <td>2.15x</td>
    <td>266.9 MiB</td>
    <td>-</td>
    <td>2.771 sec</td>
    <td>11.668 sec</td>
    <td>2.843 sec</td>
    <td>2.247 sec</td>
    <td>1.444 sec</td>
  </tr>
  <tr>
    <td>Pascal<br/>(FPC 3.2.2)</td>
    <td>24.247 sec</td>
    <td>2.48x</td>
    <td>32.5 MiB</td>
    <td>502 KiB</td>
    <td>3.249 sec</td>
    <td>5.933 sec</td>
    <td>11.254 sec</td>
    <td>2.297 sec</td>
    <td>1.514 sec</td>
  </tr>
  <tr>
    <td>Python (PyPy3)<br/>(7.3.20 / 3.11.13)</td>
    <td>29.371 sec</td>
    <td>3.01x</td>
    <td>235.2 MiB</td>
    <td>-</td>
    <td>3.346 sec</td>
    <td>12.676 sec</td>
    <td>6.141 sec</td>
    <td>2.390 sec</td>
    <td>4.818 sec</td>
  </tr>
  <tr>
    <td>PHP<br/>(8.5.9)</td>
    <td>44.903 sec</td>
    <td>4.60x</td>
    <td>153.9 MiB</td>
    <td>-</td>
    <td>3.306 sec</td>
    <td>21.076 sec</td>
    <td>7.812 sec</td>
    <td>4.385 sec</td>
    <td>8.324 sec</td>
  </tr>
  <tr>
    <td>Python 3<br/>(3.14.7)</td>
    <td>409.343 sec</td>
    <td>41.93x</td>
    <td>110.5 MiB</td>
    <td>-</td>
    <td>86.049 sec</td>
    <td>134.200 sec</td>
    <td>31.933 sec</td>
    <td>128.638 sec</td>
    <td>28.523 sec</td>
  </tr>
</tbody>
</table>
