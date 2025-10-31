<?php
ini_set('memory_limit', '4G'); // Increase memory limit for matrix multiplication
// Standardized benchmark (5 tests) matching C constants
const PRIMES_LIMIT = 20000000;
const FIBONACCI_N = 45;
const MATRIX_SIZE = 2000;
const MATRIX_RAND_MAX = 100;
const SENTENCE = 'The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again';
const STRING_OPS = 200000000;
const STRING_REDUCTION_FACTOR = 100;
const SORT_SIZE = 10000000;
const RAND_SEED = 42;

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
    printf("Fibonacci(%d) = %d in %.3f seconds\n\n", FIBONACCI_N, $r, microtime(true)-$start);
}

function benchmark_matrix_multiplication() {
    echo "Running Matrix Multiplication Benchmark (".MATRIX_SIZE."x".MATRIX_SIZE.")...\n";
    $start = microtime(true);
    mt_srand(RAND_SEED);
    $n = MATRIX_SIZE; $size = $n * $n;
    $a = $b = $c = array_fill(0, $size, 0.0);
    for ($i = 0; $i < $size; $i++) { $a[$i] = mt_rand(0, MATRIX_RAND_MAX-1); $b[$i] = mt_rand(0, MATRIX_RAND_MAX-1); }
    for ($i = 0; $i < $n; $i++) { $in = $i * $n; for ($k = 0; $k < $n; $k++) { $aik = $a[$in + $k]; $kn = $k * $n; for ($j = 0; $j < $n; $j++) { $c[$in + $j] += $aik * $b[$kn + $j]; } } }
    printf("Matrix multiplication completed in %.3f seconds\n\n", microtime(true)-$start);
}

function benchmark_sorting() {
    echo "Running Sorting Benchmark (".SORT_SIZE." elements)...\n";
    $start = microtime(true);
    mt_srand(RAND_SEED);
    $arr = [];
    for ($i = 0; $i < SORT_SIZE; $i++) $arr[] = mt_rand();
    sort($arr, SORT_REGULAR);
    printf("Sorting completed in %.3f seconds\n\n", microtime(true)-$start);
}

function benchmark_string_operations() {
    echo "Running String Operations Benchmark (".STRING_OPS." operations)...\n";
    $start = microtime(true);
    $repeats = intdiv(STRING_OPS, STRING_REDUCTION_FACTOR);
    // Efficient build
    $parts = array_fill(0, $repeats, SENTENCE);
    $hay = implode('', $parts);
    $words = explode(' ', SENTENCE);
    $total = 0;
    foreach ($words as $w) {
        $wl = strlen($w); if ($wl === 0 || $wl > strlen($hay)) continue;
        $found = 0; for ($i = 0; $i + $wl <= strlen($hay); $i++) if (substr($hay, $i, $wl) === $w) $found++;
        $total += $found;
    }
    printf("String operations completed in %.3f seconds (found %d word instances)\n\n", microtime(true)-$start, $total);
}

function main() {
    echo "=== COMPREHENSIVE PROGRAMMING LANGUAGE BENCHMARK ===\n\n";
    $total = microtime(true);
    benchmark_primes();
    benchmark_fibonacci();
    benchmark_matrix_multiplication();
    benchmark_sorting();
    benchmark_string_operations();
    echo "=== BENCHMARK COMPLETE ===\n";
    printf("Total execution time: %.3f seconds\n", microtime(true)-$total);
}

main();
?>