import std.stdio, std.datetime.stopwatch, std.format;

enum PRIMES_LIMIT = 20_000_000;
enum FIBONACCI_N = 45;

// Helper to format a Duration in fractional seconds with 3 decimals
string fmtSeconds(Duration d) {
    double secs = cast(double)d.total!"nsecs" / 1_000_000_000.0;
    return format("%.3f", secs);
}

bool isPrime(int n) {
    if (n <= 1) return false;
    if (n <= 3) return true;
    if (n % 2 == 0 || n % 3 == 0) return false;
    int i = 5;
    while (cast(long)i * i <= n) {
        if (n % i == 0 || n % (i + 2) == 0) return false;
        i += 6;
    }
    return true;
}

void benchmarkPrimes() {
    writeln("Running Prime Numbers Benchmark (up to ", PRIMES_LIMIT, ")...");
    StopWatch sw; sw.start();
    int count;
    foreach (i; 2 .. PRIMES_LIMIT) if (isPrime(i)) ++count;
    sw.stop();
    writeln("Found ", count, " primes in ", fmtSeconds(sw.peek()), " seconds\n");
}

int fib(int n) { return n <= 1 ? n : fib(n-1) + fib(n-2); }

void benchmarkFibonacci() {
    writeln("Running Fibonacci Benchmark (n=", FIBONACCI_N, ", recursive)...");
    StopWatch sw; sw.start();
    auto r = fib(FIBONACCI_N);
    sw.stop();
    writeln("Fibonacci(", FIBONACCI_N, ") = ", r, " in ", fmtSeconds(sw.peek()), " seconds\n");
}

void main() {
    writeln("=== PROGRAMMING LANGUAGE BENCHMARK (D) ===\n");
    StopWatch total; total.start();
    benchmarkPrimes();
    benchmarkFibonacci();
    total.stop();
    writeln("=== BENCHMARK COMPLETE ===");
    writeln("Total execution time: ", fmtSeconds(total.peek()), " seconds");
}