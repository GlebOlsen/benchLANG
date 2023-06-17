# Programming language benchmark! 

**Methodology:**

This is a benchmark for runtime (in seconds) and cpusage (number of threads with 100% usage).

**Benchmark type:**
* Primes
* Fibonacci

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

Command:
`C command: gcc -O3 file.c -o NAME`

### **Restults:**

* **Primes:** 1.2 - 1.5 sec (2 + threads looked like)

* **Fibonacci:** 1.12 - 1.15 sec (1 thread)

<br />

## **Rust lang:**

Command:
`rustc -O -C lto -C target-cpu=native file.rs`

### **Restults:**

* **Primes:** 1.3 - 1.5 sec (2 + threads looked like)

* **Fibonacci:** 2.3 - 2.4 sec (1 thread)


More cooming...
<hr/>

## Conclusion (Ranking):

What language is better?

Based on the scores, ease to program, online documentation and relevance:

1. **Both C or Rust:** Both are balanced so it's up to the dev's taste.
* **C lang:** Easier types, fast compile time, and lots of documentation **but** relevance is nonexistent and boomer language.
* **Rust Lang:** Safer (if you use it) alternative to C, very relevant hyped language **but** takes a little longer to write than C.

2. Coming...


**(Runtime is combined time of both benchmarks)**
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
    <td>Hard</td>
  </tr>
  <tr>
    <td>Java:</td>
    <td></td>
    <td>Hardest</td>
  </tr>
  <tr>
    <td>GO:</td>
    <td></td>
    <td>Easy</td>
  </tr>

  <tr>
    <td>C#</td>
    <td>102.488583333</td>
    <td>Hard</td>
  </tr>
  <tr>
    <td>php:</td>
    <td>376.690646171</td>
    <td>Medium</td>
  </tr>
  <tr>
    <td>python:</td>
    <td>(100 years)*5.4</td>
    <td>Easiest</td>
  </tr>
</tbody>
</table>