use std::time::Instant;

const PRIMES_LIMIT: i32 = 20_000_000;
const FIBONACCI_N: i32 = 45;
const STRING_ITER: usize = 5_000_000;
const MANDEL_W: usize = 4096;
const MANDEL_H: usize = 4096;
const MANDEL_MAX_ITER: i32 = 256;
const TREE_MIN_DEPTH: i32 = 4;
const TREE_MAX_DEPTH: i32 = 18;
const SENTENCE: &str =
    "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";

fn is_prime(n: i32) -> bool {
    if n <= 1 { return false; }
    if n <= 3 { return true; }
    if n % 2 == 0 || n % 3 == 0 { return false; }
    let mut i = 5;
    while i * i <= n {
        if n % i == 0 || n % (i + 2) == 0 { return false; }
        i += 6;
    }
    true
}
fn bench_primes() {
    let s = Instant::now();
    let mut c = 0;
    for i in 2..PRIMES_LIMIT { if is_prime(i) { c += 1; } }
    println!("Found {} primes in {:.3} seconds\n", c, s.elapsed().as_secs_f64());
}

fn fib(n: i32) -> i64 { if n <= 1 { n as i64 } else { fib(n - 1) + fib(n - 2) } }
fn bench_fib_rec() {
    let s = Instant::now();
    let r = fib(FIBONACCI_N);
    println!("Fibonacci({}) = {} in {:.3} seconds\n", FIBONACCI_N, r, s.elapsed().as_secs_f64());
}

fn bench_strings() {
    let s = Instant::now();
    let words: Vec<&str> = SENTENCE.split(' ').collect();
    let wcount = words.len();
    let mut total: u64 = 0;
    for _ in 0..STRING_ITER {
        for i in 0..wcount {
            let mut count: u64 = 0;
            for j in 0..wcount {
                if words[i] == words[j] { count += 1; }
            }
            total += count;
        }
    }
    println!("Strings: total={} in {:.3} seconds\n", total, s.elapsed().as_secs_f64());
}

fn bench_mandelbrot() {
    let s = Instant::now();
    let mut checksum: i64 = 0;
    for py in 0..MANDEL_H {
        let cy = (py as f64 / MANDEL_H as f64) * 3.0 - 1.5;
        for px in 0..MANDEL_W {
            let cx = (px as f64 / MANDEL_W as f64) * 3.0 - 2.0;
            let mut zx = 0.0_f64;
            let mut zy = 0.0_f64;
            let mut iter: i32 = 0;
            while iter < MANDEL_MAX_ITER && zx * zx + zy * zy <= 4.0 {
                let nx = zx * zx - zy * zy + cx;
                zy = 2.0 * zx * zy + cy;
                zx = nx;
                iter += 1;
            }
            checksum += iter as i64;
        }
    }
    println!("Mandelbrot: checksum={} in {:.3} seconds\n", checksum, s.elapsed().as_secs_f64());
}

struct Node {
    left: Option<Box<Node>>,
    right: Option<Box<Node>>,
    item: i64,
}

fn make_tree(item: i64, depth: i32) -> Box<Node> {
    if depth == 0 {
        Box::new(Node { left: None, right: None, item })
    } else {
        Box::new(Node {
            left: Some(make_tree(2 * item - 1, depth - 1)),
            right: Some(make_tree(2 * item, depth - 1)),
            item,
        })
    }
}

fn check_tree(n: &Node) -> i64 {
    match &n.left {
        None => n.item,
        Some(l) => n.item + check_tree(l) - check_tree(n.right.as_ref().unwrap()),
    }
}

fn bench_binary_trees() {
    let s = Instant::now();
    let mut checksum: i64 = 0;

    {
        let stretch = make_tree(0, TREE_MAX_DEPTH + 1);
        checksum += check_tree(&stretch);
    }

    let long_lived = make_tree(0, TREE_MAX_DEPTH);

    let mut d = TREE_MIN_DEPTH;
    while d <= TREE_MAX_DEPTH {
        let iters = 1i32 << (TREE_MAX_DEPTH - d + TREE_MIN_DEPTH);
        let mut sum: i64 = 0;
        for i in 0..iters {
            let t = make_tree((i + 1) as i64, d);
            sum += check_tree(&t);
        }
        checksum += sum;
        d += 2;
    }

    checksum += check_tree(&long_lived);

    println!("BinaryTrees: checksum={} in {:.3} seconds\n", checksum, s.elapsed().as_secs_f64());
}

fn main() {
    println!("=== PROGRAMMING LANGUAGE BENCHMARK ===\n");
    let s = Instant::now();
    bench_primes();
    bench_fib_rec();
    bench_strings();
    bench_mandelbrot();
    bench_binary_trees();
    println!("=== BENCHMARK COMPLETE ===");
    println!("Total execution time: {:.3} seconds", s.elapsed().as_secs_f64());
}
