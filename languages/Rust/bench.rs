use std::time::Instant;

// Constants
const PRIMES_LIMIT: u32 = 20_000_000;
const FIBONACCI_N: i32 = 45;
const SENTENCE: &str = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";

fn main() {
    println!("=== PROGRAMMING LANGUAGE BENCHMARK ===\n");
    let total_start = Instant::now();
    benchmark_primes();
    benchmark_fibonacci();
    benchmark_strings();
    let total_elapsed = total_start.elapsed();
    println!("=== BENCHMARK COMPLETE ===");
    println!("Total execution time: {:.3} seconds", total_elapsed.as_secs_f64());
}

// Optimized prime checking function
fn is_prime(n: u32) -> bool {
    if n <= 1 {
        return false;
    }
    if n <= 3 {
        return true;
    }
    if n % 2 == 0 || n % 3 == 0 {
        return false;
    }
    let mut i = 5;
    while i * i <= n {
        if n % i == 0 || n % (i + 2) == 0 {
            return false;
        }
        i += 6;
    }
    true
}

// 1. Prime number calculation using optimized algorithm
fn benchmark_primes() {
    println!("Running Prime Numbers Benchmark (up to {})...", PRIMES_LIMIT);
    let start = Instant::now();
    
    let mut prime_count = 0;
    for i in 2..PRIMES_LIMIT {
        if is_prime(i) {
            prime_count += 1;
        }
    }
    
    let elapsed = start.elapsed();
    println!("Found {} primes in {:.3} seconds\n", prime_count, elapsed.as_secs_f64());
}

// 2. Fibonacci calculation (recursive)
fn fib(n: i32) -> i32 {
    if n <= 1 {
        return n;
    }
    fib(n - 1) + fib(n - 2)
}

fn benchmark_fibonacci() {
    println!("Running Fibonacci Benchmark (n={}, recursive)...", FIBONACCI_N);
    let start = Instant::now();
    
    let result = fib(FIBONACCI_N);
    
    let elapsed = start.elapsed();
    println!("Fibonacci({}) = {} in {:.3} seconds\n", FIBONACCI_N, result, elapsed.as_secs_f64());
}

// 3. String benchmark
fn benchmark_strings() {
    println!("Running String Benchmark...");
    let start = Instant::now();
    
    let words: Vec<&str> = SENTENCE.split_whitespace().collect();
    let words_count = words.len();
    let mut match_count: i64 = 0;
    let mut reverse_count: i64 = 0;
    
    for i in 0..PRIMES_LIMIT {
        let current_word = words[(i as usize) % words_count];
        
        // Compare current word against all other words
        for other_word in &words {
            if current_word == *other_word {
                match_count += 1;
            }
        }
        
        // Extract and reverse each word from sentence
        let mut current_chars = Vec::new();
        for c in SENTENCE.chars() {
            if c == ' ' {
                if !current_chars.is_empty() {
                    // Reverse the word
                    for j in 0..current_chars.len() {
                        let _ = current_chars[current_chars.len() - 1 - j];
                    }
                    reverse_count += current_chars.len() as i64;
                    current_chars.clear();
                }
            } else {
                current_chars.push(c);
            }
        }
        // Handle last word
        if !current_chars.is_empty() {
            for j in 0..current_chars.len() {
                let _ = current_chars[current_chars.len() - 1 - j];
            }
            reverse_count += current_chars.len() as i64;
        }
    }
    
    let elapsed = start.elapsed();
    println!("Matches: {}, reverse char count: {} in {:.3} seconds\n", match_count, reverse_count, elapsed.as_secs_f64());
}
