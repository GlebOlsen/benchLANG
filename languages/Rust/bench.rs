use std::time::Instant;

// Constants
const PRIMES_LIMIT: u32 = 20_000_000;
const FIBONACCI_N: i32 = 45;

fn main() {
    println!("=== PROGRAMMING LANGUAGE BENCHMARK ===\n");
    let total_start = Instant::now();
    benchmark_primes();
    benchmark_fibonacci();
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
