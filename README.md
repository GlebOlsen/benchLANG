# Programming language benchmark! 

**Purpose:**

To find out which programming language is "faster" in terms of runtime than the others while performing the same task.

**Methodology:**

This is a benchmark for runtime (in seconds) and cpu-usage (number of threads with 100% usage).

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

## **Programming language benchmarks:**
Results are from 2024 summer:

<br/>

## **Ada lang:**

**Verison:** GNATMAKE 12.2.0

Command:

`gnatmake file.adb`

### **Restults:**

* **Primes:** 3.92 - 4.26 sec (2 + threads looked like)

* **Fibonacci:** 15.31 - 15.34 sec (1 thread)

<br />

## **C lang:**

**Verison:** gcc version 12.2.0 

Command:

`C command: gcc -O3 file.c -o NAME`

### **Restults:**

* **Primes:** 3.49 - 3.61 sec (2 + threads looked like)

* **Fibonacci:** 2.48 - 2.49 sec (1 thread)


<br />

## **D lang:**

**Verison:** GCC 12.2.0 (gdc)

Command:

`gdc file.d -o file`

### **Restults:**

* **Primes:** 3.73 - 3.84 sec (2 + threads looked like)

* **Fibonacci:** 9.59 - 9.62 sec (1 thread)

<br />

## **JS lang:**

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

`nim compile --run file.nim`

### **Restults:**

* **Primes:** 5.09 - 5.36 sec (2 + threads looked like)

* **Fibonacci:** 47.45 - 47.81 sec (1 thread)

<br />

## **Zig lang:**

**Verison:** zig 0.12.0

Command:

`zig build-exe file.zig`

### **Restults:**

* **Primes:** 5.37 - 5.57 sec (2 + threads looked like)

* **Fibonacci:** 12.06 - 12.5 sec (1 thread)

<br />

## **Rust lang:**

**Verison:** rustc 1.70.0

Command:

`rustc -O -C lto -C target-cpu=native file.rs`

### **Restults:**

* **Primes:** 3.36 - 3.59 sec (2 + threads looked like)

* **Fibonacci:** 5.57 - 5.61 sec (1 thread)


<br/>

## **GO lang:**

**Verison:** go version go1.19.8

Command:


`go build file.go`

### **Restults:**

* **Primes:** 4.91 - 5.05 sec (2 + threads looked like)

* **Fibonacci:** 8.86 - 8.94 sec (1 thread)

<br/>

## **Java lang:**

**Verison:** openjdk javac 17.0.11

Command:


`javac file.java`

### **Restults:**

* **Primes:** 3.66 - 3.87 sec (2 + threads looked like)

* **Fibonacci:** 5.41 - 5.66 sec (1 thread)

<br/>

## **C# lang:**

**Verison:** dotnet 8.0.300

Command:


```
dotnet new console
dotnet run Program.cs
```

### **Restults:**

* **Primes:** 4.90 - 5.17 (2 + threads looked like)

* **Fibonacci:** 15.86 - 15.95 sec (1 thread)

<br/>

## **PHP lang:**

**Verison:** PHP 8.2.18

Command:


`php file.php`

### **Restults:**

* **Primes:** 13.03 - 13.34 sec (2 + threads looked like)

* **Fibonacci:** 86.04 - 88.27 sec (1 thread)

<br/>

## **Python lang:**
264.215
**Verison:** Python 3.11.2

Command:

`python file.py`

### **Restults:**

* **Primes:** 41.97 - 42.08 sec (2 + threads looked like)

* **Fibonacci:** 220.57 - 223.81 sec (1 thread)

<hr/>

## Conclusion (Ranking):

What language is better?

<p>¯\_(ツ)_/¯</p>

* I would say C or Rust for fast stuff.

* GO, C#, Java or JS for some stuff.

* Python for prototyping.

Notes:

* Nim has extremely long compile times... Rust is faster but still slow compile times.
* Use GO instead of D, don't even bother with that lang for now.
* Zig is hype. 

## Calculation: 
**(Runtime is combined time of both benchmarks)**

Example from GO lang:

`(1.8 + 2.1)/2 + (4.4 + 4.7)/2` i.e: `(p_low + p_high)/2 + (f_low + f_high)/2`

## **Result table:**
"Difficulty" part of the table is based on the runtime, cpu usage, ease to program, compile time, online documentation and other.
<table>
<tbody>
    <th>Language</th>
    <th>Runtime</th>
    <th>Difficulty</th>
  <tr>
    <td>C:</td>
    <td>6.035 sec</td>
    <td>Hard</td>
  </tr>
  <tr>
    <td>Rust</td>
    <td>9.065 sec</td>
    <td>Hard</td>
  </tr>
  <tr>
    <td>Java:</td>
    <td>9.3 sec</td>
    <td>Hard</td>
  </tr>
  <tr>
    <td>D:</td>
    <td>13.39 sec</td>
    <td>Medium</td>
  </tr>
  <tr>
    <td>GO:</td>
    <td>13.87 sec</td>
    <td>Easy</td>
  </tr>
  <tr>
    <td>Zig:</td>
    <td>17.75 sec</td>
    <td>Insanity</td>
  </tr>
  <tr>
    <td>Ada:</td>
    <td>19.415 sec</td>
    <td>Hard</td>
  </tr>
  <tr>
  <tr>
    <td>C#</td>
    <td>20.939 sec</td>
    <td>Hard</td>
  </tr>
  <tr>
    <td>JS:</td>
    <td>25.84 sec</td>
    <td>Easy</td>
  </tr>
    <td>Nim:</td>
    <td>52.855 sec</td>
    <td>Hard</td>
  </tr>
  <tr>
    <td>php:</td>
    <td>100.34 sec</td>
    <td>Medium</td>
  </tr>
  <tr>
    <td>python:</td>
    <td>264.215 sec</td>
    <td>Easiest</td>
  </tr>
</tbody>
</table>