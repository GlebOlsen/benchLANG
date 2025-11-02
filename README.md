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

Results are from November 2025:
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
    <td>4.554 sec</td>
    <td>1.00x</td>
    <td>1.925 sec</td>
    <td>1.322 sec</td>
    <td>1.308 sec</td>
  </tr>
  <tr>
    <td>D<br/>(gdc 15.2.1)</td>
    <td>5.140 sec</td>
    <td>1.13x</td>
    <td>1.929 sec</td>
    <td>1.324 sec</td>
    <td>1.887 sec</td>
  </tr>
  <tr>
    <td>Zig<br/>(0.16.0-dev)</td>
    <td>5.269 sec</td>
    <td>1.16x</td>
    <td>1.928 sec</td>
    <td>2.392 sec</td>
    <td>0.949 sec</td>
  </tr>
  <tr>
    <td>Nim<br/>(2.2.4)</td>
    <td>6.462 sec</td>
    <td>1.42x</td>
    <td>2.241 sec</td>
    <td>1.176 sec</td>
    <td>3.046 sec</td>
  </tr>
  <tr>
    <td>Ada<br/>(GNAT 15.2.1)</td>
    <td>7.324 sec</td>
    <td>1.61x</td>
    <td>1.938 sec</td>
    <td>3.935 sec</td>
    <td>1.452 sec</td>
  </tr>
  <tr>
    <td>Rust<br/>(1.90.0)</td>
    <td>7.431 sec</td>
    <td>1.63x</td>
    <td>1.927 sec</td>
    <td>2.524 sec</td>
    <td>2.981 sec</td>
  </tr>
  <tr>
    <td>Fortran<br/>(GCC 15.2.1)</td>
    <td>9.184 sec</td>
    <td>2.02x</td>
    <td>1.932 sec</td>
    <td>2.566 sec</td>
    <td>4.686 sec</td>
  </tr>
  <tr>
    <td>GO<br/>(1.25.3)</td>
    <td>9.928 sec</td>
    <td>2.18x</td>
    <td>2.249 sec</td>
    <td>4.372 sec</td>
    <td>3.307 sec</td>
  </tr>
  <tr>
    <td>Pascal<br/>(FPC 3.2.2)</td>
    <td>10.840 sec</td>
    <td>2.38x</td>
    <td>2.302 sec</td>
    <td>4.307 sec</td>
    <td>4.231 sec</td>
  </tr>
  <tr>
    <td>Java<br/>(OpenJDK 25.0.1)</td>
    <td>12.221 sec</td>
    <td>2.68x</td>
    <td>1.944 sec</td>
    <td>2.877 sec</td>
    <td>7.388 sec</td>
  </tr>
  <tr>
    <td>JS (Bun)<br/>(1.3.1)</td>
    <td>13.360 sec</td>
    <td>2.93x</td>
    <td>1.962 sec</td>
    <td>5.858 sec</td>
    <td>5.540 sec</td>
  </tr>
  <tr>
    <td>JS (Node)<br/>(v24.7.0)</td>
    <td>20.721 sec</td>
    <td>4.55x</td>
    <td>1.961 sec</td>
    <td>8.618 sec</td>
    <td>10.142 sec</td>
  </tr>
  <tr>
    <td>OCaml<br/>(5.3.0)</td>
    <td>28.365 sec</td>
    <td>6.23x</td>
    <td>2.290 sec</td>
    <td>3.889 sec</td>
    <td>22.186 sec</td>
  </tr>
  <tr>
    <td>C#<br/>(.NET 10.0.100)</td>
    <td>31.273 sec</td>
    <td>6.87x</td>
    <td>2.142 sec</td>
    <td>7.690 sec</td>
    <td>21.433 sec</td>
  </tr>
  <tr>
    <td>Python (PyPy3)<br/>(3.11.13)</td>
    <td>36.510 sec</td>
    <td>8.02x</td>
    <td>2.454 sec</td>
    <td>9.354 sec</td>
    <td>24.701 sec</td>
  </tr>
  <tr>
    <td>PHP<br/>(8.4.14)</td>
    <td>143.640 sec</td>
    <td>31.54x</td>
    <td>16.086 sec</td>
    <td>51.307 sec</td>
    <td>76.247 sec</td>
  </tr>
  <tr>
    <td>Python3<br/>(3.13.7)</td>
    <td>253.658 sec</td>
    <td>55.70x</td>
    <td>68.666 sec</td>
    <td>98.441 sec</td>
    <td>86.552 sec</td>
  </tr>
</tbody>
</table>