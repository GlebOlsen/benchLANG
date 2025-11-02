# Programming language benchmark! 

**Purpose:**

To find out which programming language is "faster" in terms of runtime than the others while performing the same task.

## **Methodology:**

This is a benchmark for runtime (in seconds) and cpu-usage (number of threads with 100% usage).

The goal is to have a controlled environment. By clocking the CPU to a specific frequency and running as few services on the machinme to test all the languages with optimization parameters.

**Benchmark type:**
* Prime Numbers: Find all primes up to 20,000,000
* Fibonacci: Recursive calculation of Fibonacci(45)
* String Operations: 20M iterations of word comparison and character reversal operations

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
    <th>Total Runtime</th>
    <th>Factor of "slowness"</th>
    <th>Primes</th>
    <th>Fibonacci</th>
    <th>String Operations</th>
  <tr>
    <td>C<br/>(GCC 15.2.1)</td>
    <td>6.401 sec</td>
    <td>1.00x</td>
    <td>2.719 sec</td>
    <td>1.803 sec</td>
    <td>1.879 sec</td>
  </tr>
  <tr>
    <td>D<br/>(gdc 15.2.1)</td>
    <td>7.168 sec</td>
    <td>1.12x</td>
    <td>2.728 sec</td>
    <td>1.827 sec</td>
    <td>2.614 sec</td>
  </tr>
  <tr>
    <td>Zig<br/>(0.16.0-dev)</td>
    <td>7.332 sec</td>
    <td>1.15x</td>
    <td>2.726 sec</td>
    <td>3.301 sec</td>
    <td>1.305 sec</td>
  </tr>
  <tr>
    <td>Nim<br/>(2.2.4)</td>
    <td>8.997 sec</td>
    <td>1.41x</td>
    <td>3.165 sec</td>
    <td>1.628 sec</td>
    <td>4.204 sec</td>
  </tr>
  <tr>
    <td>Ada<br/>(GNAT 15.2.1)</td>
    <td>10.154 sec</td>
    <td>1.59x</td>
    <td>2.731 sec</td>
    <td>5.417 sec</td>
    <td>2.007 sec</td>
  </tr>
  <tr>
    <td>Rust<br/>(1.90.0)</td>
    <td>10.345 sec</td>
    <td>1.62x</td>
    <td>2.724 sec</td>
    <td>3.498 sec</td>
    <td>4.122 sec</td>
  </tr>
  <tr>
    <td>Fortran<br/>(GCC 15.2.1)</td>
    <td>13.113 sec</td>
    <td>2.05x</td>
    <td>2.717 sec</td>
    <td>3.544 sec</td>
    <td>6.851 sec</td>
  </tr>
  <tr>
    <td>GO<br/>(1.25.3)</td>
    <td>13.872 sec</td>
    <td>2.17x</td>
    <td>3.173 sec</td>
    <td>6.088 sec</td>
    <td>4.611 sec</td>
  </tr>
  <tr>
    <td>Pascal<br/>(FPC 3.2.2)</td>
    <td>15.014 sec</td>
    <td>2.35x</td>
    <td>3.247 sec</td>
    <td>5.940 sec</td>
    <td>5.827 sec</td>
  </tr>
  <tr>
    <td>Java<br/>(OpenJDK 25.0.1)</td>
    <td>16.602 sec</td>
    <td>2.59x</td>
    <td>2.729 sec</td>
    <td>3.940 sec</td>
    <td>9.917 sec</td>
  </tr>
  <tr>
    <td>JS (Bun)<br/>(1.3.1)</td>
    <td>18.338 sec</td>
    <td>2.86x</td>
    <td>2.768 sec</td>
    <td>8.042 sec</td>
    <td>7.528 sec</td>
  </tr>
  <tr>
    <td>JS (Node)<br/>(v24.7.0)</td>
    <td>30.838 sec</td>
    <td>4.82x</td>
    <td>2.760 sec</td>
    <td>13.305 sec</td>
    <td>14.772 sec</td>
  </tr>
  <tr>
    <td>OCaml<br/>(5.3.0)</td>
    <td>40.104 sec</td>
    <td>6.27x</td>
    <td>3.238 sec</td>
    <td>5.428 sec</td>
    <td>31.438 sec</td>
  </tr>
  <tr>
    <td>C#<br/>(.NET 10.0.100)</td>
    <td>40.880 sec</td>
    <td>6.39x</td>
    <td>2.936 sec</td>
    <td>10.503 sec</td>
    <td>27.430 sec</td>
  </tr>
  <tr>
    <td>Python (PyPy3)<br/>(3.11.13)</td>
    <td>49.546 sec</td>
    <td>7.74x</td>
    <td>3.362 sec</td>
    <td>12.404 sec</td>
    <td>33.780 sec</td>
  </tr>
  <tr>
    <td>PHP<br/>(8.4.14)</td>
    <td>203.260 sec</td>
    <td>31.75x</td>
    <td>22.213 sec</td>
    <td>72.447 sec</td>
    <td>108.600 sec</td>
  </tr>
  <tr>
    <td>Python3<br/>(3.13.7)</td>
    <td>354.365 sec</td>
    <td>55.36x</td>
    <td>94.789 sec</td>
    <td>137.847 sec</td>
    <td>121.729 sec</td>
  </tr>
</tbody>
</table>