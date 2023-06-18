# Programming language benchmark! 

**Purpose:**

To find out which programming language is better in terms of runtime than the others while doing the same task.

**Methodology:**

This is a benchmark for runtime (in seconds) and cpusage (number of threads with 100% usage).

**Benchmark type:**
* Primes n = 10.000.000 
* Fibonacci n = 45

**PC specs:**
* Arch 6.3.8 i3-wm
* 5900X 48gb ram with 3600mhz and 16cl

**Computer power mode:**

`sudo cpupower frequency-set -g performance`

<br/>
<hr/>

## **Language benchmarks:**
Results are from 2023 summer 06/2023:

<br/>

## **C lang:**

**Verison:** GCC 13.1.1

Command:

`C command: gcc -O3 file.c -o NAME`

### **Restults:**

* **Primes:** 1.2 - 1.5 sec (2 + threads looked like)

* **Fibonacci:** 1.12 - 1.15 sec (1 thread)

<br />

## **Rust lang:**

**Verison:** rustc 1.70.0

Command:

`rustc -O -C lto -C target-cpu=native file.rs`

### **Restults:**

* **Primes:** 1.3 - 1.5 sec (2 + threads looked like)

* **Fibonacci:** 2.3 - 2.4 sec (1 thread)


<br/>

## **GO lang:**

**Verison:** go1.20.5

Command:


`go build file.go`

### **Restults:**

* **Primes:** 1.8 - 2.1 sec (2 + threads looked like)

* **Fibonacci:** 4.4 - 4.7 sec (1 thread)

<br/>

## **Java lang:**

**Verison:** openjdk 20.0.1

Command:


`javac file.java`

### **Restults:**

* **Primes:** 1.3 - 1.7 sec (2 + threads looked like)

* **Fibonacci:** 3.5 - 3.7 sec (1 thread)

<br/>

## **C# lang:**

**Verison:** dotnet 7.0.105

Command:


```
dotnet new console
dotnet run Program.cs
```

### **Restults:**

* **Primes:** 1.6 - 2.1 sec (2 + threads looked like)

* **Fibonacci:** 7.2 - 7.7 sec (1 thread)

<br/>

## **PHP lang:**

**Verison:** PHP 8.2.7

Command:


`php file.php`

### **Restults:**

* **Primes:** 8.4 - 8.9 sec (2 + threads looked like)

* **Fibonacci:** 81 - 83 sec (1 thread)

<br/>

## **Python lang:**

**Verison:** Python 3.11.3

Command:

`python file.py`

### **Restults:**

* **Primes:** 18.2 - 18.9 sec (2 + threads looked like)

* **Fibonacci:** 101 - 103 sec (1 thread)

<hr/>

## Conclusion (Ranking):

What language is better?

Based on the runtime, cpuusage, ease to program, online documentation and relevance:

1. **Both C or Rust:** Both are balanced so it's up to the dev's taste.
* **C lang:** Easier types, fast compile time, and lots of documentation **but** relevance is nonexistent and boomer language.
* **Rust Lang:** Safer (if you use it) alternative to C, very relevant hyped language **but** takes a little longer to write than C.

2. **GO:** Really easy language and fast at the same time has lots of documentation mostly for bulding backends.

3. **Both C# or Java:** while Java is faster C# offers more features and is much easier to write than C# but setting up C# was really hard and unesseasry.

4. **Python:** Really slow but really useful because it's easy to write and has the ability to get stuff done fast like a prototype. 

5. **Php:** Really slow language has a bunch of documentation easy to setup.

**(Runtime is combined time of both benchmarks)**


Example from GO lang:

`(1.8 + 2.1)/2 + (4.4 + 4.7)/2`

## **Rusult table:**
<table>
<tbody>
    <th>Language</th>
    <th>Runtime</th>
    <th>Difficulty</th>
  <tr>
    <td>C:</td>
    <td>2.485 sec</td>
    <td>Medium</td>
  </tr>
  <tr>
    <td>Rust</td>
    <td>3.75 sec</td>
    <td>Hardest</td>
  </tr>
  <tr>
    <td>Java:</td>
    <td>4.35 sec</td>
    <td>Hard</td>
  </tr>
  <tr>
    <td>GO:</td>
    <td>6.5 sec</td>
    <td>Easy</td>
  </tr>

  <tr>
    <td>C#</td>
    <td>9.3 sec</td>
    <td>Hard</td>
  </tr>
  <tr>
    <td>php:</td>
    <td>90.65 sec</td>
    <td>Medium</td>
  </tr>
  <tr>
    <td>python:</td>
    <td>120.55 sec</td>
    <td>Easiest</td>
  </tr>
</tbody>
</table>