using System;
using System.Diagnostics;

// Constants
const int PRIMES_LIMIT = 20000000;
const int FIBONACCI_N = 45;

Console.WriteLine("=== PROGRAMMING LANGUAGE BENCHMARK ===\n");

Stopwatch totalStopwatch = Stopwatch.StartNew();

BenchmarkPrimes();
BenchmarkFibonacci();

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
