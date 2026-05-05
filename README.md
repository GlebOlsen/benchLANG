# benchLANG: Programming Language Benchmark 2026

benchLANG is a reproducible cross-language runtime benchmark comparing 18 languages across prime sieve, recursive Fibonacci, string lookup, Mandelbrot, and binary tree workloads using pinned Nix toolchains.

**Purpose:**

Find which programming language is fastest in runtime across identical tasks.

## **Latest results:**

Results from May 2026, averaged over 3 runs on a Ryzen 9 5900X locked at 3.5 GHz.

Note: Nim* has a caveat: the current `-d:danger` build compiled away the Fibonacci workload.

## **Methodology:**

This is a benchmark for runtime (in seconds) and CPU usage (number of threads with 100% usage).

The goal is to use a controlled environment: CPU locked to a fixed frequency, minimal background services, and optimized build parameters for each language.

**Benchmark type:**
* Prime Numbers: primes up to 20,000,000
* Fibonacci: recursive Fibonacci(45)
* String Operations: 5M iterations of O(n²) word equality lookup
* Mandelbrot: 4096×4096 grid, 256 iterations/pixel. FP throughput + branch prediction.
* Binary Trees: CLBG alloc/traverse (depths 4..18). Heap allocator + GC + pointer chase.

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
nix develop                  # enter shell with all toolchains pinned
./run_benchmarks.sh           # full sweep, 1 run/lang
./run_benchmarks.sh --runs 3  # 3 runs/lang, averaged in summary
./run_benchmarks.sh --only C,Rust,Zig
./analyze_results.sh          # re-print summary from latest results file
```

## **Software versions (current nix-pinned):**

| Language | Compiler / Runtime | Source |
|---|---|---|
| C / Fortran / Ada | GCC 15.2.0 (gcc / gfortran / gnat) | nixpkgs master |
| D | LDC 1.41.0 | nixpkgs master |
| Go | 1.26.2 | nixpkgs master |
| Rust | 1.95.0 | oxalica/rust-overlay |
| Zig | 0.16.0 (stable) | nixpkgs master |
| Pascal | FPC 3.2.2 | nixpkgs master |
| OCaml | 5.4.1 | nixpkgs master |
| Java | OpenJDK 25 LTS (Temurin) | Adoptium binary |
| Dart | 3.11.4 | nixpkgs master |
| Nim | 2.2.10 | nim-lang.org binary |
| C# | .NET SDK 10.0.203 | dotnet.microsoft.com binary |
| JS (Bun) | 1.3.11 | nixpkgs master |
| JS (Node) | 25.9.0 | nixpkgs master |
| PHP | 8.5.5 (with OPcache JIT) | nixpkgs master |
| Python (CPython) | 3.14.4 | python-build-standalone |
| Python (PyPy3) | 7.3.20 (Python 3.11.13) | nixpkgs master |

**Notes:** GCC pinned at 15.2.0 (nixpkgs master). GCC 16.1 is source-only upstream (gcc.gnu.org ships no Linux binary; Arch/Debian/conda-forge are also behind). `nix/gcc16.nix.bak` contains a working from-source override (~90 min build) — rename to `.nix` and re-wire flake to use it. D switched from `gdc` → `ldc2` (gdc removed from nixpkgs).

## **Optimization flags:**

| Language | Build / run command |
|---|---|
| **C** | `gcc -O3 -march=native -flto -funroll-loops -fomit-frame-pointer` |
| **Fortran** | `gfortran -O3 -march=native -funroll-loops` |
| **Ada** | `gnatmake -O3 -gnatp -gnatn -funroll-loops -finline-functions -flto -march=native` |
| **Pascal** | `fpc -O3 -OoLOOPUNROLL -OoREGVAR -CfAVX2 -Xs` |
| **D (LDC)** | `ldc2 -O3 -release -mcpu=native -flto=full` |
| **Rust** | `rustc -C opt-level=3 -C lto=fat -C target-cpu=native -C codegen-units=1 -C panic=abort` |
| **Zig** | `zig build-exe -OReleaseFast -mcpu=native` |
| **Go** | `GOAMD64=v3 CGO_ENABLED=0 go build -ldflags="-s -w" -trimpath` |
| **Nim** | `nim c -d:danger -d:lto --passC:"-O3 -flto -march=native -mtune=native -fomit-frame-pointer -funroll-loops" --passL:"-flto"` |
| **OCaml** | `ocamlopt -O3 -unsafe -nodynlink unix.cmxa` |
| **Java** | `javac` + `java -Xms512m -Xmx2g -XX:+UseG1GC` |
| **Dart** | `dart compile exe` (AOT native) |
| **C#** | `dotnet run -c Release Program.cs` |
| **PHP** | `php -d opcache.enable_cli=1 -d opcache.jit=tracing -d opcache.jit_buffer_size=256M` |
| **Python (CPython)** | `python3 -O` |
| **Python (PyPy3)** | `pypy3` (JIT default) |
| **JS (Bun / Node)** | direct interpret (JIT default) |

> Note: `-d:danger` (Nim) compiled away the Fibonacci workload. `-unsafe` (OCaml) and `-gnatp` (Ada) disable runtime safety checks for benchmark parity with C's `-ffast-math`. PHP OPcache JIT is the standard prod config for PHP 8+.

<br/>
<a id="results"></a>

## **Results:**

Results are from May 2026 (averaged over 3 runs per language):
<table>
<tbody>
    <th>Language</th>
    <th>Total Runtime</th>
    <th>Factor of "slowness"</th>
    <th>Primes</th>
    <th>Fibonacci</th>
    <th>String Operations</th>
    <th>Mandelbrot</th>
    <th>Binary Trees</th>
  <tr>
    <td>Nim*<br/>(2.2.10)</td>
    <td>8.310 sec</td>
    <td>1.00x</td>
    <td>3.161 sec</td>
    <td>0.101 sec*</td>
    <td>2.243 sec</td>
    <td>1.928 sec</td>
    <td>0.871 sec</td>
  </tr>
  <tr>
    <td>C<br/>(GCC 15.2.0)</td>
    <td>9.969 sec</td>
    <td>1.20x</td>
    <td>2.725 sec</td>
    <td>1.907 sec</td>
    <td>2.212 sec</td>
    <td>2.125 sec</td>
    <td>0.998 sec</td>
  </tr>
  <tr>
    <td>Ada<br/>(GNAT 15.2.0)</td>
    <td>10.422 sec</td>
    <td>1.25x</td>
    <td>2.729 sec</td>
    <td>1.859 sec</td>
    <td>2.585 sec</td>
    <td>2.119 sec</td>
    <td>1.130 sec</td>
  </tr>
  <tr>
    <td>Zig<br/>(0.16.0)</td>
    <td>10.640 sec</td>
    <td>1.28x</td>
    <td>2.724 sec</td>
    <td>3.183 sec</td>
    <td>1.408 sec</td>
    <td>2.212 sec</td>
    <td>1.112 sec</td>
  </tr>
  <tr>
    <td>Fortran<br/>(GCC 15.2.0)</td>
    <td>11.130 sec</td>
    <td>1.34x</td>
    <td>2.716 sec</td>
    <td>1.903 sec</td>
    <td>3.392 sec</td>
    <td>2.113 sec</td>
    <td>1.007 sec</td>
  </tr>
  <tr>
    <td>Rust<br/>(1.95.0)</td>
    <td>11.340 sec</td>
    <td>1.36x</td>
    <td>2.728 sec</td>
    <td>2.979 sec</td>
    <td>2.365 sec</td>
    <td>2.212 sec</td>
    <td>1.052 sec</td>
  </tr>
  <tr>
    <td>C#<br/>(.NET 10.0.203)</td>
    <td>12.508 sec</td>
    <td>1.51x</td>
    <td>2.735 sec</td>
    <td>3.834 sec</td>
    <td>2.769 sec</td>
    <td>2.212 sec</td>
    <td>0.956 sec</td>
  </tr>
  <tr>
    <td>D<br/>(LDC 1.41.0)</td>
    <td>13.372 sec</td>
    <td>1.61x</td>
    <td>2.722 sec</td>
    <td>2.980 sec</td>
    <td>2.624 sec</td>
    <td>2.213 sec</td>
    <td>2.834 sec</td>
  </tr>
  <tr>
    <td>Java<br/>(OpenJDK 25 LTS)</td>
    <td>13.680 sec</td>
    <td>1.65x</td>
    <td>2.729 sec</td>
    <td>4.102 sec</td>
    <td>4.250 sec</td>
    <td>2.254 sec</td>
    <td>0.338 sec</td>
  </tr>
  <tr>
    <td>Go<br/>(1.26.2)</td>
    <td>16.144 sec</td>
    <td>1.94x</td>
    <td>3.176 sec</td>
    <td>6.090 sec</td>
    <td>2.913 sec</td>
    <td>1.995 sec</td>
    <td>1.970 sec</td>
  </tr>
  <tr>
    <td>JS (Bun)<br/>(1.3.11)</td>
    <td>16.348 sec</td>
    <td>1.97x</td>
    <td>2.760 sec</td>
    <td>7.705 sec</td>
    <td>2.788 sec</td>
    <td>2.268 sec</td>
    <td>0.826 sec</td>
  </tr>
  <tr>
    <td>OCaml<br/>(5.4.1)</td>
    <td>16.821 sec</td>
    <td>2.02x</td>
    <td>3.221 sec</td>
    <td>5.429 sec</td>
    <td>5.039 sec</td>
    <td>2.272 sec</td>
    <td>0.860 sec</td>
  </tr>
  <tr>
    <td>JS (Node)<br/>(v25.9.0)</td>
    <td>19.759 sec</td>
    <td>2.38x</td>
    <td>2.755 sec</td>
    <td>11.640 sec</td>
    <td>1.623 sec</td>
    <td>2.257 sec</td>
    <td>1.483 sec</td>
  </tr>
  <tr>
    <td>Dart<br/>(3.11.4 AOT)</td>
    <td>20.386 sec</td>
    <td>2.45x</td>
    <td>2.963 sec</td>
    <td>8.242 sec</td>
    <td>6.034 sec</td>
    <td>2.270 sec</td>
    <td>0.877 sec</td>
  </tr>
  <tr>
    <td>Pascal<br/>(FPC 3.2.2)</td>
    <td>25.439 sec</td>
    <td>3.06x</td>
    <td>3.247 sec</td>
    <td>5.932 sec</td>
    <td>12.475 sec</td>
    <td>2.277 sec</td>
    <td>1.508 sec</td>
  </tr>
  <tr>
    <td>Python (PyPy3)<br/>(7.3.20 / 3.11.13)</td>
    <td>29.171 sec</td>
    <td>3.51x</td>
    <td>3.324 sec</td>
    <td>12.630 sec</td>
    <td>5.794 sec</td>
    <td>2.363 sec</td>
    <td>5.060 sec</td>
  </tr>
  <tr>
    <td>PHP<br/>(8.5.5)</td>
    <td>41.865 sec</td>
    <td>5.04x</td>
    <td>3.315 sec</td>
    <td>19.556 sec</td>
    <td>7.401 sec</td>
    <td>6.206 sec</td>
    <td>5.352 sec</td>
  </tr>
  <tr>
    <td>Python 3<br/>(3.14.4)</td>
    <td>329.522 sec</td>
    <td>39.65x</td>
    <td>66.762 sec</td>
    <td>105.587 sec</td>
    <td>41.571 sec</td>
    <td>100.230 sec</td>
    <td>15.326 sec</td>
  </tr>
</tbody>
</table>