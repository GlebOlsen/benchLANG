use std::cmp::Reverse;
use std::collections::HashMap;
use std::time::Instant;

const PRIMES_LIMIT: i32 = 8_000_000;
const FIBONACCI_N: i32 = 43;
const STRING_ITER: usize = 1_200_000;
const MANDEL_SIZE: usize = 2048;
const MANDEL_MAX_ITER: i32 = 256;
const TREE_MIN_DEPTH: i32 = 4;
const TREE_MAX_DEPTH: i32 = 17;
const SENTENCE: &str =
    "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";
const KNUC_LENGTH: usize = 6_000_000;
const KNUC_SEED: i32 = 42;
const KNUC_IM: i32 = 139968;
const KNUC_IA: i32 = 3877;
const KNUC_IC: i32 = 29573;
const KNUC_QUERY: &str = "GGTATTTTAATTTATAGT";

fn run(name: &str, bench: impl FnOnce() -> i64) {
    let t = Instant::now();
    let checksum = bench();
    let secs = t.elapsed().as_secs_f64();
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
    (2..limit).filter(|&i| is_prime(i)).count() as i64
}

fn fib(n: i32) -> i64 {
    if n < 2 { n as i64 } else { fib(n - 1) + fib(n - 2) }
}

fn bench_strings(sentence: &str, iters: usize) -> i64 {
    let words: Vec<&str> = sentence.split(' ').collect();
    let mut cur: Vec<String> = words.iter().map(|w| w.to_string()).collect();
    let mut total = 0;
    for it in 0..iters {
        let i = it % cur.len();
        cur[i] = cur[i].chars().rev().collect();
        for wi in &cur {
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
    let mut n = Box::new(Node { left: None, right: None, item });
    if depth > 0 {
        n.left = Some(make_tree(2 * item - 1, depth - 1));
        n.right = Some(make_tree(2 * item, depth - 1));
    }
    n
}

fn check_tree(n: &Node) -> i64 {
    match (&n.left, &n.right) {
        (Some(l), Some(r)) => n.item + check_tree(l) - check_tree(r),
        _ => n.item,
    }
}

fn bench_binary_trees(max_depth: i32) -> i64 {
    let mut checksum = 0;
    checksum += check_tree(&make_tree(0, max_depth + 1));
    let long_lived = make_tree(0, max_depth);
    for d in (TREE_MIN_DEPTH..=max_depth).step_by(2) {
        let iters = 1 << (max_depth - d + TREE_MIN_DEPTH);
        for i in 0..iters {
            let t = make_tree(i as i64 + 1, d);
            checksum += check_tree(&t);
        }
    }
    checksum += check_tree(&long_lived);
    checksum
}

fn bench_knucleotide(length: usize) -> i64 {
    let mut seq = vec![0u8; length];
    let mut seed = KNUC_SEED;
    for c in seq.iter_mut() {
        seed = (seed * KNUC_IA + KNUC_IC) % KNUC_IM;
        *c = if seed < 42404 { b'A' } else if seed < 70116 { b'C' } else if seed < 97766 { b'G' } else { b'T' };
    }
    let mut checksum = 0;
    for k in [1, 2, 3, 4, 6, 12, 18] {
        let mut counts: HashMap<&[u8], i32> = HashMap::new();
        for i in 0..=length - k {
            *counts.entry(&seq[i..i + k]).or_default() += 1;
        }
        checksum += counts.len() as i64;
        if k <= 2 {
            let mut entries: Vec<(&[u8], i32)> = counts.into_iter().collect();
            entries.sort_unstable_by_key(|&(key, c)| (Reverse(c), key));
            for (r, &(_, c)) in entries.iter().enumerate() {
                checksum += (r as i64 + 1) * c as i64;
            }
        } else if let Some(&c) = counts.get(&KNUC_QUERY.as_bytes()[..k]) {
            checksum += c as i64;
        }
    }
    checksum
}

fn main() {
    run("primes", || bench_primes(PRIMES_LIMIT));
    run("fib", || fib(FIBONACCI_N));
    run("strings", || bench_strings(SENTENCE, STRING_ITER));
    run("mandelbrot", || bench_mandelbrot(MANDEL_SIZE));
    run("binarytrees", || bench_binary_trees(TREE_MAX_DEPTH));
    run("knucleotide", || bench_knucleotide(KNUC_LENGTH));
}
