# Programming language benchmark! 

**Purpose:**

To find out which programming language is "faster" in terms of runtime than the others while performing the same task.

**Methodology:**

This is a benchmark for runtime (in seconds) and cpu-usage (number of threads with 100% usage).

The goal is to have a controlled environment. By clocking the CPU to a specific frequency and running as few services on the machinme to test all the languages with optimization parameters.

**Benchmark type:**
* Primes n = 10.000.000 
* Fibonacci n = 45

**PC specs:**
* Debian 6.1.90-1 i3-wm
* 5900X 48gb ram with 3600mhz and 16cl

**Computer power mode:**

`sudo cpupower frequency-set -g powersave` - This makes the CPU run at 2.2 Ghz.

<br/>
<hr/>



<br/>

## **Ada lang:**

**Verison:** GNATMAKE 12.2.0

Command:

`gnatmake -O3 file.adb`

### **Restults:**

* **Primes:** 3.92 - 4.28 sec (2 + threads looked like)

* **Fibonacci:** 15.31 - 15.34 sec (1 thread)

<br />

## **C lang:**

**Verison:** gcc version 12.2.0 

Command:

`gcc -O3 -march=native -flto -funroll-loops -fomit-frame-pointer -ffast-math file.c -o file`

### **Restults:**

* **Primes:** 3.45 - 3.60 sec (2 + threads looked like)

* **Fibonacci:** 2.24 - 2.25 sec (1 thread)


<br />

## **D lang:**

**Verison:** GCC 12.2.0 (gdc)

Command:

`gdc -O3 fib.d -o fib`

### **Restults:**

* **Primes:** 3.48 - 3.79 sec (2 + threads looked like)

* **Fibonacci:** 3.31 - 3.33 sec (1 thread)

<br />

## **JS lang:**

**Verison:** Bun 1.1.10

Command:

`bun file.js`

### **Restults:**

* **Primes:** 3.84 - 3.88 sec (2 + threads looked like)

* **Fibonacci:** 11.38 - 11.46 sec (1 thread)

### **With diff runtime:**

**Verison:** Node v21.7.3

Command:

`node file.js`

### **Restults:**

* **Primes:** 7.09 - 7.51 sec (2 + threads looked like)

* **Fibonacci:** 18.51 - 18.57 sec (1 thread)

<br />

## **Nim lang:**

**Verison:** Nim Compiler Version 1.6.10

Command:
`nim c -d:release --passC:"-flto" --passC:"-march=native" file.nim`

### **Restults:**

* **Primes:** 3.75 - 3.94 sec (2 + threads looked like) - With optimizations.

* **Fibonacci:** 0.40 sec (1 thread) - With optimization.
* **Fibonacci:** 47.45 - 47.81 sec (1 thread) - This is without optimization that "rewrites" the code.

`(3.75 + 3.94)/2 + ((47.45-0.40) + (47.81-0.40))/2 = 51.075` - This ends up to be the calculation I use. 

<br />

## **Zig lang:**

**Verison:** zig 0.12.0

Command:

`zig build-exe -OReleaseFast file.zig`

### **Restults:**

* **Primes:** 4.33 - 4.44 sec (2 + threads looked like)

* **Fibonacci:** 4.71 - 4.72 sec (1 thread)

<br />

## **Rust lang:**

**Verison:** rustc 1.70.0

Command:

`rustc -C opt-level=3 -C lto=thin -C target-cpu=native -C codegen-units=1 fib.rs`

### **Restults:**

* **Primes:** 3.34 - 3.49 sec (2 + threads looked like)

* **Fibonacci:** 5.22 - 5.23 sec (1 thread)


<br/>

## **GO lang:**

**Verison:** go version go1.19.8

Command:

`go build -ldflags="-s -w" file.go`

### **Restults:**

* **Primes:** 4.75 - 4.91 sec (2 + threads looked like)

* **Fibonacci:** 8.82 - 8.85 sec (1 thread)

<br/>

## **Java lang:**

**Verison:** openjdk javac 17.0.11

Command:
`javac file.java`

then:

`java -XX:+UseParallelGC -Xms1g -Xmx4g file`


### **Restults:**

* **Primes:** 3.66 - 3.86 sec (2 + threads looked like)

* **Fibonacci:** 5.30 - 5.45 sec (1 thread)

<br/>

## **C# lang:**

**Verison:** dotnet 8.0.300

Command:


```
dotnet new console
dotnet run Program.cs

In my case:

dotnet publish file.csproj -c Release -r linux-x64 -p:PublishReadyToRun=true -p:PublishTrimmed=true --self-contained

cd bin/Release/net8.0/linux-x64/publish

Then:

./Project_name / folder name
```

### **Restults:**

* **Primes:** 4.90 - 4.97 (2 + threads looked like)

* **Fibonacci:** 5.87 - 5.88 sec (1 thread)

<br/>

## **PHP lang:**

**Verison:** PHP 8.2.18

Command:


`php file.php`

### **Restults:**

* **Primes:** 13.03 - 13.43 sec (2 + threads looked like)

* **Fibonacci:** 85.23 - 86.98 sec (1 thread)

<br/>

## **Ocaml lang:**

**Verison:** The OCaml toplevel, version 4.13.1

Command:

`ocamlopt -O3 -nodynlink unix.cmxa file.ml -o file`

### **Restults:**

* **Primes:** 6.10 - 6.14 sec (2 + threads looked like)

* **Fibonacci:** 8.59 - 8.64 sec (1 thread)

<br/>

## **Python lang:**

**Verison:**

Python 3.9.16 (7.3.11+dfsg-2+deb12u1, Feb 02 2024, 18:54:53) 
[PyPy 7.3.11 with GCC 12.2.0]

Command:

`pypy3 file.py`

### **Restults:**

* **Primes:** 4.21 - 4.37 sec (2 + threads looked like)

* **Fibonacci:** 21.27 - 21.47 sec (1 thread)

### **With diff runtime:**

**Verison:** Python3 3.11.2

Command:

`python3 file.py`

### **Restults:**

* **Primes:** 41.97 - 42.08 sec (2 + threads looked like)

* **Fibonacci:** 220.57 - 223.81 sec (1 thread)


<hr/>


## Conclusion (Ranking):

What language is "better"?

<p>¯\_(ツ)_/¯</p>

* Use any language you like since performance doesn't really matter when you run optimization params.

* Python for mostly prototyping.

* Don't use PHP for anything.

Notes:

* Nim has extremely long compile times... Rust is faster but still slow compile times.
* Use GO instead of D, don't even bother with that lang for now.
* Zig is hype. 

## Calculation: 
**(Runtime is combined time of both benchmarks)**

Example from GO lang:

`(4.87 + 4.92)/2 + (8.829 + 8.828)/2` i.e: `(p_low + p_high)/2 + (f_low + f_high)/2`

## **Result table:**
"Difficulty" part of the table is based on the runtime, cpu usage, ease to program, compile time, online documentation and other.

Results are from 2024 summer:
<table>
<tbody>
    <th>Language</th>
    <th>Runtime</th>
    <th>Difficulty</th>
  <tr>
    <td>C:</td>
    <td>5.77 sec</td>
    <td>Hard</td>
  </tr>
  <tr>
    <td>D:</td>
    <td>6.95 sec</td>
    <td>Medium</td>
  </tr>
  <tr>
    <td>Rust</td>
    <td>8.64 sec</td>
    <td>Hard</td>
  </tr>
  <tr> 
    <td>Zig:</td>
    <td>9.10 sec</td>
    <td>Insanity</td>
  </tr>
  <tr>
    <td>Java:</td>
    <td>9.13 sec</td>
    <td>Hard</td>
  </tr>
  <tr>
    <td>C#</td>
    <td>10.81 sec</td>
    <td>Really Hard</td>
  </tr>
  <tr>
    <td>Ada:</td>
    <td>12.92 sec</td>
    <td>Hard</td>
  </tr>
  <tr>
    <td>GO:</td>
    <td>13.66 sec</td>
    <td>Easy</td>
  </tr>
  <tr>
    <td>OCaml:</td>
    <td>14.735 sec</td>
    <td>Hard</td>
  </tr>
  <tr>
    <td>JS (Bun):</td>
    <td>15.28 sec</td>
    <td>Very easy</td>
  </tr>
  <tr>
    <td>python (pypy3):</td>
    <td>25.65 sec</td>
    <td>Easiest</td>
  </tr>
    <tr>
    <td>JS (Node):</td>
    <td>25.84 sec</td>
    <td>Easy</td>
  </tr>
  <tr>
    <td>Nim:</td>
    <td>51.075 sec</td>
    <td>Hard</td>
  </tr>
  <tr>
    <td>php:</td>
    <td>99.33 sec</td>
    <td>Medium</td>
  </tr>
    <tr>
    <td>python (python3):</td>
    <td>264.215 sec</td>
    <td>Easiest</td>
  </tr>
</tbody>
</table>
