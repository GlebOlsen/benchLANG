using System;
using System.Diagnostics;
using System.Text;

// Constants
const int PRIMES_LIMIT = 20000000;
const int FIBONACCI_N = 45;
const int MATRIX_SIZE = 2000;
const int MATRIX_RAND_MAX = 100;
const string SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";
const int STRING_OPS = 200000000;
const int STRING_REDUCTION_FACTOR = 100;
const int SORT_SIZE = 10000000;
const int RAND_SEED = 42;

Console.WriteLine("=== COMPREHENSIVE PROGRAMMING LANGUAGE BENCHMARK ===\n");

Stopwatch totalStopwatch = Stopwatch.StartNew();

BenchmarkPrimes();
BenchmarkFibonacci();
BenchmarkMatrixMultiplication();
BenchmarkSorting();
BenchmarkStringOperations();

totalStopwatch.Stop();

Console.WriteLine("=== BENCHMARK COMPLETE ===");
Console.WriteLine($"Total execution time: {totalStopwatch.Elapsed.TotalSeconds:F3} seconds");

// Optimized prime checking function
static bool IsPrime(int n) {
    if (n <= 1)
        return false;
    if (n <= 3)
        return true;
    if (n % 2 == 0 || n % 3 == 0)
        return false;
    int i = 5;
    while (i * i <= n) {
        if (n % i == 0 || n % (i + 2) == 0)
            return false;
        i += 6;
    }
    return true;
}

// 1. Prime number calculation using optimized algorithm
static void BenchmarkPrimes() {
    Console.WriteLine($"Running Prime Numbers Benchmark (up to {PRIMES_LIMIT})...");
    Stopwatch stopwatch = Stopwatch.StartNew();
    
    int primeCount = 0;
    for (int i = 2; i < PRIMES_LIMIT; i++) {
        if (IsPrime(i)) {
            primeCount++;
        }
    }
    
    stopwatch.Stop();
    Console.WriteLine($"Found {primeCount} primes in {stopwatch.Elapsed.TotalSeconds:F3} seconds\n");
}

// 2. Fibonacci calculation (recursive)
static int Fib(int n) {
    if (n <= 1) {
        return n;
    }
    return Fib(n - 1) + Fib(n - 2);
}

static void BenchmarkFibonacci() {
    Console.WriteLine($"Running Fibonacci Benchmark (n={FIBONACCI_N}, recursive)...");
    Stopwatch stopwatch = Stopwatch.StartNew();
    
    int result = Fib(FIBONACCI_N);
    
    stopwatch.Stop();
    Console.WriteLine($"Fibonacci({FIBONACCI_N}) = {result} in {stopwatch.Elapsed.TotalSeconds:F3} seconds\n");
}

// 3. Matrix multiplication
static void BenchmarkMatrixMultiplication() {
    Console.WriteLine($"Running Matrix Multiplication Benchmark ({MATRIX_SIZE}x{MATRIX_SIZE})...");
    Stopwatch stopwatch = Stopwatch.StartNew();
    
    Random rand = new Random(RAND_SEED);
    int n = MATRIX_SIZE;
    int elems = n * n;
    double[] a = new double[elems];
    double[] b = new double[elems];
    double[] c = new double[elems];
    
    // Initialize matrices
    for (int i = 0; i < elems; i++) {
        a[i] = rand.Next(MATRIX_RAND_MAX);
        b[i] = rand.Next(MATRIX_RAND_MAX);
        c[i] = 0;
    }
    
    // Matrix multiplication
    for (int i = 0; i < n; i++) {
        for (int k = 0; k < n; k++) {
            double aik = a[i * n + k];
            for (int j = 0; j < n; j++) {
                c[i * n + j] += aik * b[k * n + j];
            }
        }
    }
    
    stopwatch.Stop();
    Console.WriteLine($"Matrix multiplication completed in {stopwatch.Elapsed.TotalSeconds:F3} seconds\n");
}

// 4. Sorting
static void BenchmarkSorting()
{
    Console.WriteLine($"Running Sorting Benchmark ({SORT_SIZE} elements)...");
    Stopwatch stopwatch = Stopwatch.StartNew();
    
    Random rand = new Random(RAND_SEED);
    int[] arr = new int[SORT_SIZE];
    
    for (int i = 0; i < SORT_SIZE; i++) {
        arr[i] = rand.Next();
    }
    
    Array.Sort(arr);
    
    stopwatch.Stop();
    Console.WriteLine($"Sorting completed in {stopwatch.Elapsed.TotalSeconds:F3} seconds\n");
}

// 5. String operations
static void BenchmarkStringOperations()
{
    Console.WriteLine($"Running String Operations Benchmark ({STRING_OPS} operations)...");
    Stopwatch stopwatch = Stopwatch.StartNew();
    
    string sentence = SENTENCE;
    StringBuilder result = new StringBuilder();
    
    for (int i = 0; i < STRING_OPS / STRING_REDUCTION_FACTOR; i++) {
        result.Append(sentence);
    }
    
    // Dynamic word extraction and searching (matching C's O(n*m) behavior)
    string resultString = result.ToString();
    string[] words = sentence.Split(' ');
    
    int totalFound = 0;
    foreach (string word in words) {
        int foundCount = 0;
        // Manual string search to match C's strstr behavior
        for (int i = 0; i <= resultString.Length - word.Length; i++) {
            if (resultString.Substring(i, word.Length) == word) {
                foundCount++;
            }
        }
        totalFound += foundCount;
    }
    
    stopwatch.Stop();
    Console.WriteLine($"String operations completed in {stopwatch.Elapsed.TotalSeconds:F3} seconds (found {totalFound} word instances)\n");
}
