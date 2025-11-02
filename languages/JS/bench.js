const PRIMES_LIMIT = 20000000;
const FIBONACCI_N = 45;
const SENTENCE = "The quick brown fox jumps over dat lazy dog that was not enough to jump over the frog again";

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

// 3. String benchmark
function benchmarkStrings() {
    console.log("Running String Benchmark...");
    const start = Date.now();
    
    const words = SENTENCE.split(' ');
    const wordsCount = words.length;
    let matchCount = 0;
    let reverseCount = 0;
    
    for (let i = 0; i < PRIMES_LIMIT; i++) {
        const currentWord = words[i % wordsCount];
        
        // Compare current word against all other words
        for (const otherWord of words) {
            if (currentWord === otherWord) {
                matchCount++;
            }
        }
        
        // Extract and reverse each word from sentence
        let currentChars = [];
        for (let k = 0; k < SENTENCE.length; k++) {
            if (SENTENCE[k] === ' ') {
                if (currentChars.length > 0) {
                    // Reverse the word
                    for (let rev = 0; rev < currentChars.length; rev++) {
                        const temp = currentChars[currentChars.length - 1 - rev];
                    }
                    reverseCount += currentChars.length;
                    currentChars = [];
                }
            } else {
                currentChars.push(SENTENCE[k]);
            }
        }
        // Handle last word
        if (currentChars.length > 0) {
            for (let rev = 0; rev < currentChars.length; rev++) {
                const temp = currentChars[currentChars.length - 1 - rev];
            }
            reverseCount += currentChars.length;
        }
    }
    
    const elapsed = (Date.now() - start) / 1000;
    console.log(`Matches: ${matchCount}, reverse char count: ${reverseCount} in ${elapsed.toFixed(3)} seconds\n`);
}

// Main
(function main() {
    console.log("=== PROGRAMMING LANGUAGE BENCHMARK ===\n");
    const totalStart = Date.now();
    
    benchmarkPrimes();
    benchmarkFibonacci();
    benchmarkStrings();
    
    const totalElapsed = (Date.now() - totalStart) / 1000;
    console.log("=== BENCHMARK COMPLETE ===");
    console.log(`Total execution time: ${totalElapsed.toFixed(3)} seconds`);
})();
