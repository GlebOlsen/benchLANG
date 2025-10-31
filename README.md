# Programming language benchmark! 

**Purpose:**

To find out which programming language is "faster" in terms of runtime than the others while performing the same task.

## **Methodology:**

This is a benchmark for runtime (in seconds) and cpu-usage (number of threads with 100% usage).

The goal is to have a controlled environment. By clocking the CPU to a specific frequency and running as few services on the machinme to test all the languages with optimization parameters.

**Benchmark type:**
* Prime Numbers: Find all primes up to 20,000,000
* Fibonacci: Recursive calculation of Fibonacci(45)

**PC specs:**
* Arch i3-wm (Bloated i3)
* 5900X 48gb ram with 3600mhz and 16cl

**Computer power mode:**

`sudo cpupower frequency-set -g performance`
```
sudo cpupower frequency-set --max 3500Mhz
sudo cpupower frequency-set --min 3500Mhz
```
**(This makes the CPU run at 3.5 Ghz.)**
<br/>
## **Results:**

Results are from October 2025:
<table>
<tbody>
    <th>Language</th>
    <th>Runtime</th>
  <tr>
    <td>C:</td>
    <td>3.272 sec</td>
  </tr>
  <tr>
    <td>D:</td>
    <td>3.254 sec</td>
  </tr>
  <tr>
    <td>Nim:</td>
    <td>3.375 sec</td>
  </tr>
  <tr>
    <td>Rust:</td>
    <td>4.236 sec</td>
  </tr>
  <tr>
    <td>Zig:</td>
    <td>4.341 sec</td>
  </tr>
  <tr>
    <td>Java:</td>
    <td>4.853 sec</td>
  </tr>
  <tr>
    <td>OCaml:</td>
    <td>6.284 sec</td>
  </tr>
  <tr>
    <td>Pascal:</td>
    <td>6.622 sec</td>
  </tr>
  <tr>
    <td>GO:</td>
    <td>6.669 sec</td>
  </tr>
  <tr>
    <td>JS (Bun):</td>
    <td>7.946 sec</td>
  </tr>
  <tr>
    <td>C#:</td>
    <td>10.223 sec</td>
  </tr>
  <tr>
    <td>JS (Node):</td>
    <td>10.644 sec</td>
  </tr>
  <tr>
    <td>Python (PyPy3):</td>
    <td>11.581 sec</td>
  </tr>
  <tr>
    <td>PHP:</td>
    <td>70.558 sec</td>
  </tr>
  <tr>
    <td>Python3:</td>
    <td>169.853 sec</td>
  </tr>
  <tr>
    <td>Ada:</td>
    <td>Optimized away (1.941 sec)</td>
  </tr>
  <tr>
    <td>Fortran:</td>
    <td>Optimized away (1.926 sec)</td>
  </tr>
</tbody>
</table>
