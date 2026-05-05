const PRIMES_LIMIT = 20_000_000;
const FIBONACCI_N = 45;
const STRING_ITER = 5_000_000;
const MANDEL_W = 4096;
const MANDEL_H = 4096;
const MANDEL_MAX_ITER = 256;
const TREE_MIN_DEPTH = 4;
const TREE_MAX_DEPTH = 18;
const SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";

function isPrime(n) {
    if (n <= 1) return false;
    if (n <= 3) return true;
    if (n % 2 === 0 || n % 3 === 0) return false;
    for (let i = 5; i * i <= n; i += 6)
        if (n % i === 0 || n % (i + 2) === 0) return false;
    return true;
}
function benchPrimes() {
    const s = performance.now();
    let count = 0;
    for (let i = 2; i < PRIMES_LIMIT; i++) if (isPrime(i)) count++;
    console.log(`Found ${count} primes in ${((performance.now() - s) / 1000).toFixed(3)} seconds\n`);
}

function fib(n) { return n <= 1 ? n : fib(n - 1) + fib(n - 2); }
function benchFibRec() {
    const s = performance.now();
    const r = fib(FIBONACCI_N);
    console.log(`Fibonacci(${FIBONACCI_N}) = ${r} in ${((performance.now() - s) / 1000).toFixed(3)} seconds\n`);
}

function benchStrings() {
    const s = performance.now();
    const words = SENTENCE.split(' ');
    const wcount = words.length;
    let total = 0;
    for (let iter = 0; iter < STRING_ITER; iter++) {
        for (let i = 0; i < wcount; i++) {
            let count = 0;
            for (let j = 0; j < wcount; j++) {
                if (words[i] === words[j]) count++;
            }
            total += count;
        }
    }
    console.log(`Strings: total=${total} in ${((performance.now() - s) / 1000).toFixed(3)} seconds\n`);
}

function benchMandelbrot() {
    const s = performance.now();
    let checksum = 0;
    for (let py = 0; py < MANDEL_H; py++) {
        const cy = (py / MANDEL_H) * 3.0 - 1.5;
        for (let px = 0; px < MANDEL_W; px++) {
            const cx = (px / MANDEL_W) * 3.0 - 2.0;
            let zx = 0.0, zy = 0.0;
            let iter = 0;
            while (iter < MANDEL_MAX_ITER && zx * zx + zy * zy <= 4.0) {
                const nx = zx * zx - zy * zy + cx;
                zy = 2.0 * zx * zy + cy;
                zx = nx;
                iter++;
            }
            checksum += iter;
        }
    }
    console.log(`Mandelbrot: checksum=${checksum} in ${((performance.now() - s) / 1000).toFixed(3)} seconds\n`);
}

function makeTree(item, depth) {
    if (depth === 0) return { left: null, right: null, item: item };
    return { left: makeTree(2 * item - 1, depth - 1), right: makeTree(2 * item, depth - 1), item: item };
}
function checkTree(n) {
    if (n.left === null) return n.item;
    return n.item + checkTree(n.left) - checkTree(n.right);
}
function benchBinaryTrees() {
    const s = performance.now();
    let checksum = 0;
    {
        const stretch = makeTree(0, TREE_MAX_DEPTH + 1);
        checksum += checkTree(stretch);
    }
    const longLived = makeTree(0, TREE_MAX_DEPTH);
    for (let d = TREE_MIN_DEPTH; d <= TREE_MAX_DEPTH; d += 2) {
        const iters = 1 << (TREE_MAX_DEPTH - d + TREE_MIN_DEPTH);
        let sum = 0;
        for (let i = 0; i < iters; i++) {
            const t = makeTree(i + 1, d);
            sum += checkTree(t);
        }
        checksum += sum;
    }
    checksum += checkTree(longLived);
    console.log(`BinaryTrees: checksum=${checksum} in ${((performance.now() - s) / 1000).toFixed(3)} seconds\n`);
}

console.log("=== PROGRAMMING LANGUAGE BENCHMARK ===\n");
const total = performance.now();
benchPrimes();
benchFibRec();
benchStrings();
benchMandelbrot();
benchBinaryTrees();
console.log("=== BENCHMARK COMPLETE ===");
console.log(`Total execution time: ${((performance.now() - total) / 1000).toFixed(3)} seconds`);
