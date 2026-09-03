const PRIMES_LIMIT = 20_000_000;
const FIBONACCI_N = 45;
const STRING_ITER = 5_000_000;
const MANDEL_SIZE = 4096;
const MANDEL_MAX_ITER = 256;
const TREE_MIN_DEPTH = 4;
const TREE_MAX_DEPTH = 18;
const SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";

function report(name, checksum, ms) {
    console.log(`${name} ${checksum} ${(ms / 1000).toFixed(3)}`);
}

function isPrime(n) {
    if (n < 2) return false;
    if (n < 4) return true;
    if (n % 2 === 0 || n % 3 === 0) return false;
    for (let i = 5; i * i <= n; i += 6)
        if (n % i === 0 || n % (i + 2) === 0) return false;
    return true;
}

function benchPrimes(limit) {
    let count = 0;
    for (let i = 2; i < limit; i++)
        if (isPrime(i)) count++;
    return count;
}

function fib(n) { return n < 2 ? n : fib(n - 1) + fib(n - 2); }

function benchStrings(sentence, iters) {
    const words = sentence.split(' ');
    let total = 0;
    for (let it = 0; it < iters; it++)
        for (const wi of words)
            for (const wj of words)
                if (wi === wj) total++;
    return total;
}

function benchMandelbrot(size) {
    let checksum = 0;
    for (let py = 0; py < size; py++) {
        const cy = py / size * 3.0 - 1.5;
        for (let px = 0; px < size; px++) {
            const cx = px / size * 3.0 - 2.0;
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
    return checksum;
}

function makeTree(item, depth) {
    if (depth === 0) return { left: null, right: null, item };
    return { left: makeTree(2 * item - 1, depth - 1), right: makeTree(2 * item, depth - 1), item };
}

function checkTree(n) {
    if (n.left === null) return n.item;
    return n.item + checkTree(n.left) - checkTree(n.right);
}

function benchBinaryTrees(maxDepth) {
    let checksum = 0;
    {
        const stretch = makeTree(0, maxDepth + 1);
        checksum += checkTree(stretch);
    }
    const longLived = makeTree(0, maxDepth);
    for (let d = TREE_MIN_DEPTH; d <= maxDepth; d += 2) {
        const iters = 1 << (maxDepth - d + TREE_MIN_DEPTH);
        for (let i = 0; i < iters; i++)
            checksum += checkTree(makeTree(i + 1, d));
    }
    checksum += checkTree(longLived);
    return checksum;
}

let t, r;
t = performance.now(); r = benchPrimes(PRIMES_LIMIT);          report("primes", r, performance.now() - t);
t = performance.now(); r = fib(FIBONACCI_N);                   report("fib", r, performance.now() - t);
t = performance.now(); r = benchStrings(SENTENCE, STRING_ITER); report("strings", r, performance.now() - t);
t = performance.now(); r = benchMandelbrot(MANDEL_SIZE);        report("mandelbrot", r, performance.now() - t);
t = performance.now(); r = benchBinaryTrees(TREE_MAX_DEPTH);    report("binarytrees", r, performance.now() - t);
