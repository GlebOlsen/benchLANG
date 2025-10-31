import std.stdio, std.datetime.stopwatch, std.random, std.algorithm.sorting, std.array, std.string, std.format;

enum PRIMES_LIMIT = 20_000_000;
enum FIBONACCI_N = 45;
enum MATRIX_SIZE = 2000;
enum MATRIX_RAND_MAX = 100;
enum SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";
enum STRING_OPS = 200_000_000;
enum STRING_REDUCTION_FACTOR = 100;
enum SORT_SIZE = 10_000_000;
enum RAND_SEED = 42;

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

// Flat matrices (row-major)
__gshared double[] matrixA;
__gshared double[] matrixB;
__gshared double[] matrixC;

void ensureMatrices() {
    if (matrixA.length == 0) {
        matrixA.length = MATRIX_SIZE * MATRIX_SIZE;
        matrixB.length = MATRIX_SIZE * MATRIX_SIZE;
        matrixC.length = MATRIX_SIZE * MATRIX_SIZE;
    }
}

void benchmarkMatrixMultiplication() {
    writeln("Running Matrix Multiplication Benchmark (", MATRIX_SIZE, "x", MATRIX_SIZE, ")...");
    StopWatch sw; sw.start();
    ensureMatrices();
    auto rng = Random(RAND_SEED);
    foreach (i; 0 .. matrixA.length) {
        matrixA[i] = uniform(0, MATRIX_RAND_MAX, rng);
        matrixB[i] = uniform(0, MATRIX_RAND_MAX, rng);
        matrixC[i] = 0;
    }
    immutable n = MATRIX_SIZE;
    foreach (i; 0 .. n) {
        auto inIdx = i * n;
        foreach (k; 0 .. n) {
            auto aik = matrixA[inIdx + k];
            auto knIdx = k * n;
            foreach (j; 0 .. n) matrixC[inIdx + j] += aik * matrixB[knIdx + j];
        }
    }
    sw.stop();
    writeln("Matrix multiplication completed in ", fmtSeconds(sw.peek()), " seconds\n");
}

__gshared int[] sortArray;

void benchmarkSorting() {
    writeln("Running Sorting Benchmark (", SORT_SIZE, " elements)...");
    StopWatch sw; sw.start();
    sortArray.length = SORT_SIZE;
    auto rng = Random(RAND_SEED);
    foreach (i; 0 .. SORT_SIZE) sortArray[i] = cast(int)(uniform!uint(rng) & 0x7FFF_FFFF);
    sort(sortArray); // in-place
    sw.stop();
    writeln("Sorting completed in ", fmtSeconds(sw.peek()), " seconds\n");
}

void benchmarkStringOperations() {
    writeln("Running String Operations Benchmark (", STRING_OPS, " operations)...");
    StopWatch sw; sw.start();
    immutable repeats = STRING_OPS / STRING_REDUCTION_FACTOR;
    auto builder = appender!string();
    builder.reserve(SENTENCE.length * repeats);
    foreach (_; 0 .. repeats) builder.put(SENTENCE);
    auto hay = builder.data; // large concatenated string
    auto words = SENTENCE.split(' ');
    size_t total;
    foreach (w; words) {
        if (w.length == 0 || w.length > hay.length) continue;
        size_t found;
        foreach (i; 0 .. hay.length - w.length + 1) {
            if (hay[i .. i + w.length] == w) ++found;
        }
        total += found;
    }
    sw.stop();
    writeln("String operations completed in ", fmtSeconds(sw.peek()), " seconds (found ", total, " word instances)\n");
}

void main() {
    writeln("=== COMPREHENSIVE PROGRAMMING LANGUAGE BENCHMARK (D) ===\n");
    StopWatch total; total.start();
    benchmarkPrimes();
    benchmarkFibonacci();
    benchmarkMatrixMultiplication();
    benchmarkSorting();
    benchmarkStringOperations();
    total.stop();
    writeln("=== BENCHMARK COMPLETE ===");
    writeln("Total execution time: ", fmtSeconds(total.peek()), " seconds");
}