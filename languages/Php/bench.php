<?php
const PRIMES_LIMIT = 20000000;
const FIBONACCI_N = 45;
const SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";

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

function benchmark_strings() {
    echo "Running String Benchmark...\n";
    $start = microtime(true);
    $words = explode(' ', SENTENCE);
    $words_count = count($words);
    $match_count = 0;
    $reverse_count = 0;
    
    for ($i = 0; $i < PRIMES_LIMIT; $i++) {
        $current_word = $words[$i % $words_count];
        
        // Compare current word against all other words
        foreach ($words as $other_word) {
            if ($current_word === $other_word) {
                $match_count++;
            }
        }
        
        // Extract and reverse each word from sentence
        $current_chars = [];
        for ($k = 0; $k < strlen(SENTENCE); $k++) {
            if (SENTENCE[$k] === ' ') {
                if (count($current_chars) > 0) {
                    // Reverse the word
                    for ($rev = 0; $rev < count($current_chars); $rev++) {
                        $temp = $current_chars[count($current_chars) - 1 - $rev];
                    }
                    $reverse_count += count($current_chars);
                    $current_chars = [];
                }
            } else {
                $current_chars[] = SENTENCE[$k];
            }
        }
        // Handle last word
        if (count($current_chars) > 0) {
            for ($rev = 0; $rev < count($current_chars); $rev++) {
                $temp = $current_chars[count($current_chars) - 1 - $rev];
            }
            $reverse_count += count($current_chars);
        }
    }
    
    printf("Matches: %d, reverse char count: %d in %.3f seconds\n\n", $match_count, $reverse_count, microtime(true)-$start);
}

function main() {
    echo "=== PROGRAMMING LANGUAGE BENCHMARK ===\n\n";
    $total = microtime(true);
    benchmark_primes();
    benchmark_fibonacci();
    benchmark_strings();
    echo "=== BENCHMARK COMPLETE ===\n";
    printf("Total execution time: %.3f seconds\n", microtime(true)-$total);
}

main();
?>