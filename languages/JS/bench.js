// Standardized constants (match C benchmark)
const PRIMES_LIMIT = 20000000;
const FIBONACCI_N = 45;
const MATRIX_SIZE = 2000;
const MATRIX_RAND_MAX = 100;
const SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";
const STRING_OPS = 200000000;
const STRING_REDUCTION_FACTOR = 100;
const SORT_SIZE = 10000000;
const RAND_SEED = 42;

// Simple PRNG for reproducible results
class SimpleRandom {
    constructor(seed = 42) {
        this.seed = seed;
    }
    
    next() {
        this.seed = (this.seed * 1103515245 + 12345) & 0x7fffffff;
        return this.seed;
    }
    
    nextInt(max) {
        return Math.abs(this.next()) % max;
    }
    
    nextFloat(min = 0, max = 1) {
        return min + (this.next() / 0x7fffffff) * (max - min);
    }
}

console.log("=== COMPREHENSIVE PROGRAMMING LANGUAGE BENCHMARK ===\n");

const totalStart = Date.now();

benchmarkPrimes();
benchmarkFibonacci();
benchmarkMatrixMultiplication();
benchmarkSorting();
benchmarkStringOperations();

const totalEnd = Date.now();
console.log("=== BENCHMARK COMPLETE ===");
console.log(`Total execution time: ${((totalEnd - totalStart) / 1000).toFixed(3)} seconds`);

// Optimized prime checking function
function isPrime(n) {
    if (n <= 1) return false;
    if (n <= 3) return true;
    if (n % 2 === 0 || n % 3 === 0) return false;
    let i = 5;
    while (i * i <= n) {
        if (n % i === 0 || n % (i + 2) === 0) return false;
        i += 6;
    }
    return true;
}

// 1. Prime number calculation using optimized algorithm
function benchmarkPrimes() {
    console.log(`Running Prime Numbers Benchmark (up to ${PRIMES_LIMIT})...`);
    const start = Date.now();
    
    let primeCount = 0;
    for (let i = 2; i < PRIMES_LIMIT; i++) {
        if (isPrime(i)) {
            primeCount++;
        }
    }
    
    const elapsed = (Date.now() - start) / 1000;
    console.log(`Found ${primeCount} primes in ${elapsed.toFixed(3)} seconds\n`);
}

// 2. Fibonacci calculation (recursive)
function fib(n) {
    if (n <= 1) {
        return n;
    }
    return fib(n - 1) + fib(n - 2);
}

function benchmarkFibonacci() {
    console.log(`Running Fibonacci Benchmark (n=${FIBONACCI_N}, recursive)...`);
    const start = Date.now();
    
    const result = fib(FIBONACCI_N);
    
    const elapsed = (Date.now() - start) / 1000;
    console.log(`Fibonacci(${FIBONACCI_N}) = ${result} in ${elapsed.toFixed(3)} seconds\n`);
}

// 3. Matrix multiplication
function benchmarkMatrixMultiplication() {
    console.log(`Running Matrix Multiplication Benchmark (${MATRIX_SIZE}x${MATRIX_SIZE})...`);
    const start = Date.now();
    const rng = new SimpleRandom(RAND_SEED);
    const n = MATRIX_SIZE; const size = n * n;
    const a = new Float64Array(size);
    const b = new Float64Array(size);
    const c = new Float64Array(size);
    for (let i = 0; i < size; i++) { a[i] = rng.nextInt(MATRIX_RAND_MAX); b[i] = rng.nextInt(MATRIX_RAND_MAX); }
    for (let i = 0; i < n; i++) {
        const inIdx = i * n;
        for (let k = 0; k < n; k++) {
            const aik = a[inIdx + k];
            const knIdx = k * n;
            for (let j = 0; j < n; j++) c[inIdx + j] += aik * b[knIdx + j];
        }
    }
    console.log(`Matrix multiplication completed in ${((Date.now()-start)/1000).toFixed(3)} seconds\n`);
}

// 4. Sorting (use built-in Array.sort with numeric comparator)
function partition(arr, low, high) {
    const pivot = arr[high];
    let i = low - 1;
    
    for (let j = low; j <= high - 1; j++) {
        if (arr[j] < pivot) {
            i++;
            [arr[i], arr[j]] = [arr[j], arr[i]]; // Swap
        }
    }
    [arr[i + 1], arr[high]] = [arr[high], arr[i + 1]]; // Swap pivot
    return i + 1;
}

function quickSort(arr, low, high) {
    if (low < high) {
        const pi = partition(arr, low, high);
        quickSort(arr, low, pi - 1);
        quickSort(arr, pi + 1, high);
    }
}

function benchmarkSorting() {
    console.log(`Running Sorting Benchmark (${SORT_SIZE} elements)...`);
    const start = Date.now();
    const rng = new SimpleRandom(RAND_SEED);
    const arr = new Array(SORT_SIZE);
    for (let i = 0; i < SORT_SIZE; i++) arr[i] = rng.next();
    arr.sort((a,b)=>a-b);
    console.log(`Sorting completed in ${((Date.now()-start)/1000).toFixed(3)} seconds\n`);
}

// 5. String operations
function benchmarkStringOperations() {
    console.log(`Running String Operations Benchmark (${STRING_OPS} operations)...`);
    const start = Date.now();
    const repeats = STRING_OPS / STRING_REDUCTION_FACTOR;
    let pieces = new Array(repeats);
    for (let i = 0; i < repeats; i++) pieces[i] = SENTENCE;
    const hay = pieces.join('');
    const words = SENTENCE.split(' ');
    let total = 0;
    for (const w of words) {
        if (!w || w.length > hay.length) continue;
        let found = 0;
        for (let i = 0; i + w.length <= hay.length; i++) {
            if (hay.substring(i, i + w.length) === w) found++;
        }
        total += found;
    }
    console.log(`String operations completed in ${((Date.now()-start)/1000).toFixed(3)} seconds (found ${total} word instances)\n`);
}

// (Removed memory, recursion, floating point to align with standard 5-test suite)
