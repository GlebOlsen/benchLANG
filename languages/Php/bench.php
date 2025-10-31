<?php
const PRIMES_LIMIT = 20000000;
const FIBONACCI_N = 45;

function is_prime(int $n): bool {
    if ($n <= 1) return false;
    if ($n <= 3) return true;
    if ($n % 2 === 0 || $n % 3 === 0) return false;
    for ($i = 5; $i * $i <= $n; $i += 6) {
        if ($n % $i === 0 || $n % ($i + 2) === 0) return false;
    }
    return true;
}

function benchmark_primes() {
    echo "Running Prime Numbers Benchmark (up to ".PRIMES_LIMIT.")...\n";
    $start = microtime(true);
    $count = 0;
    for ($i = 2; $i < PRIMES_LIMIT; $i++) if (is_prime($i)) $count++;
    printf("Found %d primes in %.3f seconds\n\n", $count, microtime(true)-$start);
}

function fib(int $n): int { return $n <= 1 ? $n : fib($n-1) + fib($n-2); }

function benchmark_fibonacci() {
    echo "Running Fibonacci Benchmark (n=".FIBONACCI_N.", recursive)...\n";
    $start = microtime(true);
    $r = fib(FIBONACCI_N);
    printf("Fibonacci(%d) = %d in %.3f seconds\n\n", FIBONACCI_N, $result, microtime(true)-$start);
}

function main() {
    echo "=== PROGRAMMING LANGUAGE BENCHMARK ===\n\n";
    $total = microtime(true);
    benchmark_primes();
    benchmark_fibonacci();
    echo "=== BENCHMARK COMPLETE ===\n";
    printf("Total execution time: %.3f seconds\n", microtime(true)-$total);
}

main();
?>