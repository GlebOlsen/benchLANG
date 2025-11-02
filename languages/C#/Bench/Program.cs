using System;
using System.Diagnostics;

// Constants
const int PRIMES_LIMIT = 20000000;
const int FIBONACCI_N = 45;
const string SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";

Console.WriteLine("=== PROGRAMMING LANGUAGE BENCHMARK ===\n");

Stopwatch totalStopwatch = Stopwatch.StartNew();

BenchmarkPrimes();
BenchmarkFibonacci();
BenchmarkStrings();

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

// 3. String benchmark
static void BenchmarkStrings() {
    Console.WriteLine("Running String Benchmark...");
    Stopwatch stopwatch = Stopwatch.StartNew();

    string[] words = SENTENCE.Split(' ');
    int wordsCount = words.Length;
    long matchCount = 0;
    long reverseCount = 0;

    for (int i = 0; i < PRIMES_LIMIT; i++) {
        string currentWord = words[i % wordsCount];
        
        // Compare current word against all other words
        foreach (string otherWord in words) {
            if (currentWord == otherWord) {
                matchCount++;
            }
        }
        
        // Extract and reverse each word from sentence
        System.Text.StringBuilder currentChars = new System.Text.StringBuilder();
        foreach (char c in SENTENCE) {
            if (c == ' ') {
                if (currentChars.Length > 0) {
                    char[] charArray = currentChars.ToString().ToCharArray();
                    Array.Reverse(charArray);
                    string reverseWord = new string(charArray);
                    reverseCount += reverseWord.Length;
                    currentChars.Clear();
                }
            } else {
                currentChars.Append(c);
            }
        }
        // Handle last word
        if (currentChars.Length > 0) {
            char[] charArray = currentChars.ToString().ToCharArray();
            Array.Reverse(charArray);
            string reverseWord = new string(charArray);
            reverseCount += reverseWord.Length;
        }
    }

    stopwatch.Stop();
    Console.WriteLine($"Matches: {matchCount}, reverse char count: {reverseCount} in {stopwatch.Elapsed.TotalSeconds:F3} seconds\n");
}
