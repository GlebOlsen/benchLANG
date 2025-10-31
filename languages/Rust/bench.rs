use std::time::Instant;

// Constants (standardized with C benchmark)
const PRIMES_LIMIT: u32 = 20_000_000;
const FIBONACCI_N: i32 = 45;
const MATRIX_SIZE: usize = 2000;
const MATRIX_RAND_MAX: u32 = 100;
const SENTENCE: &str = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";
const STRING_OPS: usize = 200_000_000;
const STRING_REDUCTION_FACTOR: usize = 100;
const SORT_SIZE: usize = 10_000_000;
const RAND_SEED: u64 = 42;

struct SimpleRng { state: u64 }
impl SimpleRng { fn new(seed: u64) -> Self { Self { state: seed } } fn next(&mut self) -> u64 { self.state = self.state.wrapping_mul(1103515245).wrapping_add(12345); self.state } }

fn main() {
    println!("=== COMPREHENSIVE PROGRAMMING LANGUAGE BENCHMARK ===\n");
    let total_start = Instant::now();
    benchmark_primes();
    benchmark_fibonacci();
    benchmark_matrix_multiplication();
    benchmark_sorting();
    benchmark_string_operations();
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

// 3. Arithmetic operations
// Removed arithmetic / memory / recursion / floating point per 5-test standard

// 4. Matrix multiplication
fn benchmark_matrix_multiplication() {
    println!("Running Matrix Multiplication Benchmark ({}x{})...", MATRIX_SIZE, MATRIX_SIZE);
    let start = Instant::now();
    let mut rng = SimpleRng::new(RAND_SEED);
    let n = MATRIX_SIZE;
    let size = n * n;
    let mut a = vec![0f64; size];
    let mut b = vec![0f64; size];
    let mut c = vec![0f64; size];
    for i in 0..size { a[i] = (rng.next() % MATRIX_RAND_MAX as u64) as f64; b[i] = (rng.next() % MATRIX_RAND_MAX as u64) as f64; }
    for i in 0..n { let in_idx = i * n; for k in 0..n { let aik = a[in_idx + k]; let kn_idx = k * n; for j in 0..n { c[in_idx + j] += aik * b[kn_idx + j]; } } }
    println!("Matrix multiplication completed in {:.3} seconds\n", start.elapsed().as_secs_f64());
}

// 5. Quick sort algorithm
fn benchmark_sorting() {
    println!("Running Sorting Benchmark ({} elements)...", SORT_SIZE);
    let start = Instant::now();
    let mut rng = SimpleRng::new(RAND_SEED);
    let mut arr: Vec<i32> = (0..SORT_SIZE).map(|_| (rng.next() & 0x7fff_ffff) as i32).collect();
    arr.sort_unstable();
    println!("Sorting completed in {:.3} seconds\n", start.elapsed().as_secs_f64());
}

// 6. String operations
fn benchmark_string_operations() {
    println!("Running String Operations Benchmark ({} operations)...", STRING_OPS);
    let start = Instant::now();
    let repeats = STRING_OPS / STRING_REDUCTION_FACTOR;
    let mut s = String::with_capacity(SENTENCE.len() * repeats);
    for _ in 0..repeats { s.push_str(SENTENCE); }
    let hay = s.as_bytes();
    let words: Vec<&str> = SENTENCE.split(' ').collect();
    let mut total = 0usize;
    for w in words { if w.is_empty() || w.len() > hay.len() { continue; } let wb = w.as_bytes(); let wl = wb.len(); for i in 0..=hay.len()-wl { if &hay[i..i+wl] == wb { total += 1; } } }
    println!("String operations completed in {:.3} seconds (found {} word instances)\n", start.elapsed().as_secs_f64(), total);
}

// 7. Memory allocation/deallocation
// Removed memory / recursion / floating point benchmarks
