const PRIMES_LIMIT = 8_000_000;
const FIBONACCI_N = 43;
const STRING_ITER = 1_200_000;
const MANDEL_SIZE = 2048;
const MANDEL_MAX_ITER = 256;
const TREE_MIN_DEPTH = 4;
const TREE_MAX_DEPTH = 17;
const SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";
const KNUC_LENGTH = 6_000_000;
const KNUC_SEED = 42;
const KNUC_IM = 139968;
const KNUC_IA = 3877;
const KNUC_IC = 29573;
const KNUC_QUERY = "GGTATTTTAATTTATAGT";

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
    const cur = [...words];
    let total = 0;
    for (let it = 0; it < iters; it++) {
        const i = it % words.length;
        cur[i] = cur[i].split('').reverse().join('');
        for (const wi of cur)
            for (const wj of words)
                if (wi === wj) total++;
    }
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
    let checksum = checkTree(makeTree(0, maxDepth + 1));
    const longLived = makeTree(0, maxDepth);
    for (let d = TREE_MIN_DEPTH; d <= maxDepth; d += 2) {
        const iters = 1 << (maxDepth - d + TREE_MIN_DEPTH);
        for (let i = 0; i < iters; i++)
            checksum += checkTree(makeTree(i + 1, d));
    }
    checksum += checkTree(longLived);
    return checksum;
}

function benchKnucleotide(length) {
    const buf = new Uint8Array(length);
    let seed = KNUC_SEED;
    for (let i = 0; i < length; i++) {
        seed = (seed * KNUC_IA + KNUC_IC) % KNUC_IM;
        buf[i] = seed < 42404 ? 65 : seed < 70116 ? 67 : seed < 97766 ? 71 : 84;
    }
    const seq = new TextDecoder().decode(buf);
    let checksum = 0;
    for (const k of [1, 2, 3, 4, 6, 12, 18]) {
        const counts = new Map();
        for (let i = 0; i + k <= length; i++) {
            const key = seq.slice(i, i + k);
            counts.set(key, (counts.get(key) ?? 0) + 1);
        }
        checksum += counts.size;
        if (k <= 2) {
            const entries = [...counts].sort(([ka, ca], [kb, cb]) => cb - ca || (ka < kb ? -1 : ka > kb ? 1 : 0));
            for (const [r, [, c]] of entries.entries()) checksum += (r + 1) * c;
        } else {
            checksum += counts.get(KNUC_QUERY.slice(0, k)) ?? 0;
        }
    }
    return checksum;
}

let t, r;
t = performance.now(); r = benchPrimes(PRIMES_LIMIT);          report("primes", r, performance.now() - t);
t = performance.now(); r = fib(FIBONACCI_N);                   report("fib", r, performance.now() - t);
t = performance.now(); r = benchStrings(SENTENCE, STRING_ITER); report("strings", r, performance.now() - t);
t = performance.now(); r = benchMandelbrot(MANDEL_SIZE);        report("mandelbrot", r, performance.now() - t);
t = performance.now(); r = benchBinaryTrees(TREE_MAX_DEPTH);    report("binarytrees", r, performance.now() - t);
t = performance.now(); r = benchKnucleotide(KNUC_LENGTH);       report("knucleotide", r, performance.now() - t);
