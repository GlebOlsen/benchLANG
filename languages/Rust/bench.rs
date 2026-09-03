use std::time::Instant;

const PRIMES_LIMIT: i32 = 20_000_000;
const FIBONACCI_N: i32 = 45;
const STRING_ITER: usize = 5_000_000;
const MANDEL_SIZE: usize = 4096;
const MANDEL_MAX_ITER: i32 = 256;
const TREE_MIN_DEPTH: i32 = 4;
const TREE_MAX_DEPTH: i32 = 18;
const SENTENCE: &str =
    "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";

fn report(name: &str, checksum: i64, secs: f64) {
    println!("{name} {checksum} {secs:.3}");
}

fn is_prime(n: i32) -> bool {
    if n < 2 { return false; }
    if n < 4 { return true; }
    if n % 2 == 0 || n % 3 == 0 { return false; }
    let mut i = 5;
    while i * i <= n {
        if n % i == 0 || n % (i + 2) == 0 { return false; }
        i += 6;
    }
    true
}

fn bench_primes(limit: i32) -> i64 {
    let mut count = 0;
    for i in 2..limit {
        if is_prime(i) { count += 1; }
    }
    count
}

fn fib(n: i32) -> i64 {
    if n < 2 { n as i64 } else { fib(n - 1) + fib(n - 2) }
}

fn bench_strings(sentence: &str, iters: usize) -> i64 {
    let words: Vec<&str> = sentence.split(' ').collect();
    let mut total = 0;
    for _ in 0..iters {
        for wi in &words {
            for wj in &words {
                if wi == wj { total += 1; }
            }
        }
    }
    total
}

fn bench_mandelbrot(size: usize) -> i64 {
    let mut checksum = 0;
    for py in 0..size {
        let cy = py as f64 / size as f64 * 3.0 - 1.5;
        for px in 0..size {
            let cx = px as f64 / size as f64 * 3.0 - 2.0;
            let (mut zx, mut zy) = (0.0f64, 0.0f64);
            let mut iter = 0;
            while iter < MANDEL_MAX_ITER && zx * zx + zy * zy <= 4.0 {
                let nx = zx * zx - zy * zy + cx;
                zy = 2.0 * zx * zy + cy;
                zx = nx;
                iter += 1;
            }
            checksum += iter as i64;
        }
    }
    checksum
}

struct Node {
    left: Option<Box<Node>>,
    right: Option<Box<Node>>,
    item: i64,
}

fn make_tree(item: i64, depth: i32) -> Box<Node> {
    if depth == 0 {
        return Box::new(Node { left: None, right: None, item });
    }
    Box::new(Node {
        left: Some(make_tree(2 * item - 1, depth - 1)),
        right: Some(make_tree(2 * item, depth - 1)),
        item,
    })
}

fn check_tree(n: &Node) -> i64 {
    match (&n.left, &n.right) {
        (Some(l), Some(r)) => n.item + check_tree(l) - check_tree(r),
        _ => n.item,
    }
}

fn bench_binary_trees(max_depth: i32) -> i64 {
    let mut checksum = 0;
    {
        let stretch = make_tree(0, max_depth + 1);
        checksum += check_tree(&stretch);
    }
    let long_lived = make_tree(0, max_depth);
    let mut d = TREE_MIN_DEPTH;
    while d <= max_depth {
        let iters = 1 << (max_depth - d + TREE_MIN_DEPTH);
        for i in 0..iters {
            let t = make_tree(i as i64 + 1, d);
            checksum += check_tree(&t);
        }
        d += 2;
    }
    checksum += check_tree(&long_lived);
    checksum
}

fn main() {
    let mut t;
    let mut r;
    t = Instant::now(); r = bench_primes(PRIMES_LIMIT);          report("primes", r, t.elapsed().as_secs_f64());
    t = Instant::now(); r = fib(FIBONACCI_N);                     report("fib", r, t.elapsed().as_secs_f64());
    t = Instant::now(); r = bench_strings(SENTENCE, STRING_ITER); report("strings", r, t.elapsed().as_secs_f64());
    t = Instant::now(); r = bench_mandelbrot(MANDEL_SIZE);        report("mandelbrot", r, t.elapsed().as_secs_f64());
    t = Instant::now(); r = bench_binary_trees(TREE_MAX_DEPTH);   report("binarytrees", r, t.elapsed().as_secs_f64());
}
